SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionNextRenewalUpdate2] 
@TransactionID as varchar(Max)
AS
/*  Author:			Robin John
	Date created:	29 May 2013
	Purpose:		To update the renewal date in  bulk based on the status inserted by the web service for the recently processed subscriptions.
	Behaviour:		Based on the Status received from the web service, updates the Next renewal date and processing status
	Usage:			Often in batch
	Called by:		Web Service
	WarmUP Script:	Execute [tescosubscription].[CustomerSubscriptionNextRenewalUpdate1]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	27 Jun 2013     Robin                            Versioned and added logic for NextPaymentDate
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
		SET CS.NextRenewalDate      =   CASE    
										WHEN PaymentStatusID = @SuccessPaymentStatus AND IP.PaymentInstallmentID = 1
										THEN DATEADD(m,SP.PlanTenure+DATEDIFF(M,CS.RenewalReferenceDate,CS.NextRenewalDate), CS.RenewalReferenceDate) 
										WHEN PaymentStatusID = @SuccessPaymentStatus AND IP.PaymentInstallmentID <> 1  AND DATEDIFF(d,CS.NextRenewalDate,CS.NextPaymentDate) >= 0
                                        THEN DATEADD(m,SP.PlanTenure+DATEDIFF(M,CS.RenewalReferenceDate,CS.NextRenewalDate), CS.RenewalReferenceDate) 
                                        ELSE CS.NextRenewalDate END
												--    Card Failure
		 ,CS.SubscriptionStatus		=   CASE PaymentStatusID 
										WHEN @CardFailurePaymentStatus THEN  @SuspendedSubscriptionStatus
										ELSE CS.SubscriptionStatus END                                       
		 ,CS.PaymentProcessStatus   =   @SuccessPaymentProcessStatus
		 ,UTCUpdatedDateTime=@CurrentUTCDate
         ,CS.NextPaymentDate        =  CASE 
                                       WHEN PaymentStatusID = @SuccessPaymentStatus AND IP.PaymentInstallmentID <>1
                                       THEN DATEADD(M,IP.InstallmentTenure+DATEDIFF(M,CS.RenewalReferenceDate,CS.NextPaymentDate), CS.RenewalReferenceDate)
                                       ELSE CS.NextPaymentDate END
                                             

	FROM  #CustomerSubscriptionInProgress CPHLatest	
	JOIN  tescosubscription.CustomerPaymentHistory CPH ON  CPHLatest.CustomerPaymentHistoryID	   =     CPH.CustomerPaymentHistoryID 
	JOIN  tescosubscription.CustomerPaymentHistoryResponse CPHR ON  CPHLatest.CustomerPaymentHistoryID	   =     CPHR.CustomerPaymentHistoryID 
	JOIN tescosubscription.CustomerSubscription CS	ON  CPH.CustomerSubscriptionID=CS.CustomerSubscriptionID                                                                          
	JOIN  tescosubscription.SubscriptionPlan SP          ON    CS.SubscriptionPlanID         =      SP.SubscriptionPlanID
    JOIN tescosubscription.PaymentInstallment IP ON   SP.PaymentInstallmentID  =  IP.PaymentInstallmentID
	WHERE CS.PaymentProcessStatus = @InProgressPaymentProcessStatus  -- this check will prevent double updates in case the service retries
	
	
		
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
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionNextRenewalUpdate2] TO [SubsUser]
GO
