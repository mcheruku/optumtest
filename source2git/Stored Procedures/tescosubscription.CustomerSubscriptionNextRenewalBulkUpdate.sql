SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionNextRenewalBulkUpdate] 
AS
/*  Author:			Rajendra Singh
	Date created:	21 Jun 2011
	Purpose:		To update the renewal date in  bulk based on the status inserted by the web service for the recently processed subscriptions.
	Behaviour:		Based on the Status received from the web service, updates the Next renewal date and processing status
	Usage:			Often in batch
	Called by:		Web Service
	WarmUP Script:	Execute [tescosubscription].[CustomerSubscriptionNextRenewalBulkUpdate]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	<29 Jun 2011>	<Thulasi>						<Month Logic>
	<04 Jul 2011>	<Manju>							<New calculation logic in Month Logic,Added cases>
	<12 Jul 2011>	<Thulasi>						<Subscription Status in Customer Subscription>
	<25 Jul 2011>	<Thulasi>						<update the status, IsFirstPaymentDue as false in the CustomerPayment if it is true>
    <29 Aug 2011>    Rajendra						 Added logic to to insert SuspendedSubscription Status Customer subscription history 
    <30 Sep 2011>    <Thulasi>						 Renamed as CustomerSubscriptionNextRenewalBulkUpdate and is not used by the scheduler service.

*/
BEGIN
	DECLARE @SuccessPaymentProcessStatus TINYINT
            ,@InProgressPaymentProcessStatus TINYINT
			,@SuccessPaymentStatus TINYINT
			,@CardFailurePaymentStatus TINYINT
			,@SuspendedSubscriptionStatus TINYINT
			,@CurrentUTCDate DATETIME
			,@PreAuthAmount SMALLMONEY
			,@errorDescription				    NVARCHAR(2048)
			,@error								INT
			,@errorProcedure					SYSNAME
			,@errorLine							INT
	
	SET NOCOUNT ON;

   SELECT @SuccessPaymentProcessStatus = 6 ,@InProgressPaymentProcessStatus = 5,@CurrentUTCDate = GETUTCDATE(), @SuccessPaymentStatus = 1,
			@CardFailurePaymentStatus = 2, @SuspendedSubscriptionStatus = 7, @PreAuthAmount = 2
		
	BEGIN TRY

	CREATE TABLE #CustomerSubscriptionInProgress
	(CustomerPaymentHistoryID BIGINT)
	
	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		
		
	INSERT INTO #CustomerSubscriptionInProgress
	SELECT MAX(CustomerPaymentHistoryID) CustomerPaymentHistoryID FROM  tescosubscription.CustomerSubscription CS  With (nolock)
	JOIN tescosubscription.CustomerPaymentHistory CPH 	With (nolock) ON CS.CustomerSubscriptionID=CPH.CustomerSubscriptionID 
													AND CS.PaymentProcessStatus = @InProgressPaymentProcessStatus
													AND CPH.PaymentDate > NextRenewalDate
					GROUP BY CPH.CustomerSubscriptionID
		
	BEGIN TRANSACTION UpdatePaymentAndSubscription
	
	UPDATE CS
										    -- Success Case
		SET CS.NextRenewalDate            =   CASE PaymentStatusID 
										WHEN @SuccessPaymentStatus 
										THEN DATEADD(m,SP.PlanTenure+datediff(m,CS.RenewalReferenceDate,CS.NextRenewalDate), CS.RenewalReferenceDate) 
										ELSE CS.NextRenewalDate END
												--    Card Failure
		 ,CS.SubscriptionStatus		=   CASE PaymentStatusID 
										WHEN @CardFailurePaymentStatus THEN  @SuspendedSubscriptionStatus
										ELSE CS.SubscriptionStatus END                                       
		 ,CS.PaymentProcessStatus      =     @SuccessPaymentProcessStatus
		 ,UTCUpdatedDateTime=@CurrentUTCDate
	FROM  #CustomerSubscriptionInProgress CPHLatest	
	JOIN  tescosubscription.CustomerPaymentHistory CPH ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID 
	JOIN tescosubscription.CustomerSubscription CS	ON  CPH.CustomerSubscriptionID=CS.CustomerSubscriptionID                                                                          
	JOIN  tescosubscription.SubscriptionPlan SP          ON    CS.SubscriptionPlanID         =      SP.SubscriptionPlanID
	WHERE CS.PaymentProcessStatus = @InProgressPaymentProcessStatus
	
	UPDATE	CP
		SET		CP.IsFirstPaymentDue = 0,UTCUpdatedDateTime=@CurrentUTCDate
	FROM  #CustomerSubscriptionInProgress CPHLatest
	JOIN tescosubscription.CustomerPaymentHistory CPH	ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID                                                                            
	JOIN tescosubscription.CustomerPayment CP			ON	CP.CustomerPaymentID	=	 CPH.CustomerPaymentID
		  WHERE CP.IsFirstPaymentDue = 1 
			--AND CPH.PaymentAmount > @PreAuthAmount 
			AND CPH.PaymentStatusID = @SuccessPaymentStatus
	
		
	COMMIT TRANSACTION UpdatePaymentAndSubscription
	
	/*Insert into Customer subscription history in case of SuspendedSubscription Status*/	
	INSERT INTO tescosubscription.CustomerSubscriptionHistory (CustomerSubscriptionID, SubscriptionStatus, Remarks)
	SELECT CustomerSubscriptionID, @SuspendedSubscriptionStatus, CPH.Remarks
	FROM  #CustomerSubscriptionInProgress CPHLatest
	JOIN tescosubscription.CustomerPaymentHistory CPH	ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID                                                                            
	WHERE CPH.PaymentStatusID = @CardFailurePaymentStatus
	
	END TRY
	BEGIN CATCH

      SELECT      @errorProcedure         = Routine_Schema  + '.' + Routine_Name
                  , @error                = ERROR_NUMBER()
                  , @errorDescription     = ERROR_MESSAGE()
                  , @errorLine            = ERROR_LINE()
      FROM  INFORMATION_SCHEMA.ROUTINES
      WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

     ROLLBACK TRANSACTION UpdatePaymentAndSubscription

	 RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
	 

	END CATCH

	DROP TABLE #CustomerSubscriptionInProgress
	
END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionNextRenewalBulkUpdate] TO [SubsUser]
GO
