SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionNextRenewalUpdate] 
@TransactionID as varchar(Max)
AS
/*  Author:			Rajendra Singh
	Date created:	21 Jun 2011
	Purpose:		To update the renewal date in  bulk based on the status inserted by the web service for the recently processed subscriptions.
	Behaviour:		Based on the Status received from the web service, updates the Next renewal date and processing status
	Usage:			Often in batch
	Called by:		Web Service
	WarmUP Script:	Execute [tescosubscription].[CustomerSubscriptionNextRenewalUpdate]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	<29 Jun 2011>	<Thulasi>						<Month Logic>
	<04 Jul 2011>	<Manju>							<New calculation logic in Month Logic,Added cases>
	<12 Jul 2011>	<Thulasi>						<Subscription Status in Customer Subscription>
	<25 Jul 2011>	<Thulasi>						<update the status, IsFirstPaymentDue as false in the CustomerPayment if it is true>
    <29 Aug 2011>   <Rajendra>						 Added logic to to insert SuspendedSubscription Status Customer subscription history 
    <27 Sep 2011>	<Manjunathan>					<Takes an input of comma separated transaction IDs.update based on the transaction IDs>
	06 Jan	2012	Manjunathan Raman				Added changes to incorporate new table - payment history response
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
			,@chrind INT
			,@Piece BIGINT
	
		SET NOCOUNT ON;

   SELECT @SuccessPaymentProcessStatus = 6 ,@InProgressPaymentProcessStatus = 5,@CurrentUTCDate = GETUTCDATE(), @SuccessPaymentStatus = 1,
			@CardFailurePaymentStatus = 2, @SuspendedSubscriptionStatus = 7, @PreAuthAmount = 2,@chrind = 1
		
	BEGIN TRY
	
	CREATE  TABLE #CustomerSubscriptionInProgress(CustomerPaymentHistoryID BIGINT)

	WHILE @chrind > 0
	BEGIN
		SELECT @chrind = CHARINDEX(',',@TransactionID)
		IF @chrind > 0
			SELECT @Piece = LEFT(@TransactionID,@chrind - 1)
		ELSE
			SELECT @Piece = @TransactionID
		INSERT #CustomerSubscriptionInProgress(CustomerPaymentHistoryID) VALUES(@Piece)
		SELECT @TransactionID = RIGHT(@TransactionID,LEN(@TransactionID) - @chrind)
		IF LEN(@TransactionID) = 0 BREAK
	END

	BEGIN TRANSACTION UpdatePaymentAndSubscription
	UPDATE CS
										  -- Success Case
		SET CS.NextRenewalDate      =   CASE PaymentStatusID 
										WHEN @SuccessPaymentStatus 
										THEN DATEADD(m,SP.PlanTenure+datediff(m,CS.RenewalReferenceDate,CS.NextRenewalDate), CS.RenewalReferenceDate) 
										ELSE CS.NextRenewalDate END
												--    Card Failure
		 ,CS.SubscriptionStatus		=   CASE PaymentStatusID 
										WHEN @CardFailurePaymentStatus THEN  @SuspendedSubscriptionStatus
										ELSE CS.SubscriptionStatus END                                       
		 ,CS.PaymentProcessStatus   =   @SuccessPaymentProcessStatus
		 ,UTCUpdatedDateTime=@CurrentUTCDate
	FROM  #CustomerSubscriptionInProgress CPHLatest	
	JOIN  tescosubscription.CustomerPaymentHistory CPH ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID 
	JOIN  tescosubscription.CustomerPaymentHistoryResponse CPHR ON  CPHLatest.CustomerPaymentHistoryID	   =     CPHR.CustomerPaymentHistoryID 
	JOIN tescosubscription.CustomerSubscription CS	ON  CPH.CustomerSubscriptionID=CS.CustomerSubscriptionID                                                                          
	JOIN  tescosubscription.SubscriptionPlan SP          ON    CS.SubscriptionPlanID         =      SP.SubscriptionPlanID
	WHERE CS.PaymentProcessStatus = @InProgressPaymentProcessStatus  -- this check will prevent double updates in case the service retries
	
	UPDATE	CP
		SET		CP.IsFirstPaymentDue = 0,UTCUpdatedDateTime=@CurrentUTCDate
	FROM  #CustomerSubscriptionInProgress CPHLatest
	JOIN tescosubscription.CustomerPaymentHistory CPH	ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID                                                                            
	JOIN  tescosubscription.CustomerPaymentHistoryResponse CPHR ON  CPHLatest.CustomerPaymentHistoryID	   =     CPHR.CustomerPaymentHistoryID 
	JOIN tescosubscription.CustomerPayment CP			ON	CP.CustomerPaymentID	=	 CPH.CustomerPaymentID
    WHERE CP.IsFirstPaymentDue = 1 
	AND CPHR.PaymentStatusID = @SuccessPaymentStatus
	
		
	COMMIT TRANSACTION UpdatePaymentAndSubscription
	
	--Insert into Customer subscription history in case of SuspendedSubscription Status
	INSERT INTO tescosubscription.CustomerSubscriptionHistory (CustomerSubscriptionID, SubscriptionStatus, Remarks)
	SELECT CustomerSubscriptionID, @SuspendedSubscriptionStatus, CPHR.Remarks
	FROM  #CustomerSubscriptionInProgress CPHLatest
	JOIN tescosubscription.CustomerPaymentHistory CPH	ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID                                                                            
	JOIN  tescosubscription.CustomerPaymentHistoryResponse CPHR ON  CPHLatest.CustomerPaymentHistoryID	   =     CPHR.CustomerPaymentHistoryID 
	WHERE CPHR.PaymentStatusID = @CardFailurePaymentStatus
	
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
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionNextRenewalUpdate] TO [SubsUser]
GO
