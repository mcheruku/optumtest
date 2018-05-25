SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerSubscriptionUpdate1]
(
@CustomerSubscriptionID bigint,
@SubscriptionPlanID		int,
@CustomerPlanStartDate  datetime, 
@CustomerPlanEndDate    datetime,
@NextRenewalDate        datetime,
@RenewalReferenceDate   datetime,
@SubscriptionStatus     tinyint,
@PaymentProcessStatus   tinyint,
@Remarks                varchar(400),
@NextPaymentDate		datetime-- Calculated next payment date value which is passed from DS website in case of updating the card details for suspended customers
)
AS

/*

	Author:			Saminathan
	Date created:	18/08/2011
	Purpose:		Updates Customer subscription Details	
	Behaviour:		How does this procedure actually work
	Usage:			
	Called by:		<JUVO>
	--exec [tescosubscription].[CustomerSubscriptionUpdate1] 2018,69, null,null,null,null,9,6,'Test remarks-sami for stop'

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
    26 Aug 2011		Saminathan						Modified Subs status from Stoppped to Pending Stop
    13 Sep 2011		Saritha K						Modified IF ..ELSE condition
	06 Dec 2012     Robin							Added UTC Date
	04 Jun 2013		Robin							Added NextPaymentDate parameter and added logic for nextpaymentdate
*/
BEGIN

     DECLARE @errorDescription	NVARCHAR(2048)
			,@error				INT
			,@errorProcedure    SYSNAME
			,@errorLine	        INT
 			,@SwitchToExisting INT
			,@SwitchStatusCancel TINYINT
			,@SwitchOrigin VARCHAR(60)
	
	
	BEGIN TRY
	BEGIN TRANSACTION CustomerSubscriptionUpdate
	
       --Updates History when status change
    IF(@SubscriptionStatus is not null)
  BEGIN	
	INSERT INTO tescosubscription.CustomerSubscriptionHistory
					(
					CustomerSubscriptionID,
					SubscriptionStatus,
					Remarks					
					)
		VALUES
					(
					@CustomerSubscriptionID,
					@SubscriptionStatus,
					@Remarks
					)
--Plan Cancel and PendingStop is only from Juvo and not from Web, below is exception
--Plan Pendingstop from web is possible only if it was already PendingStop and Suspended and this is possible only for Installment plans
--Condition to find above is (@NextPaymentDate is null ), from web @NextPaymentDate is not null from Juvo it is Null
IF(@SubscriptionStatus=9 OR @SubscriptionStatus=11) AND @NextPaymentDate is null --When subsription status is cancel update enddate with current date  
  BEGIN  
   SELECT @CustomerPlanEndDate=
	CASE WHEN @SubscriptionStatus=9 THEN 
		getdate() 
	ELSE
		NextRenewalDate
	END,
	@SwitchStatusCancel = 18, @SwitchToExisting=SwitchTo , @SwitchOrigin='Juvo'
	FROM  tescosubscription.CustomerSubscription WHERE CustomerSubscriptionID=@CustomerSubscriptionID 

	IF @SwitchToExisting IS NOT NULL
	BEGIN
	INSERT INTO [tescosubscription].[CustomerSubscriptionSwitchHistory]
			   (
				    [CustomerSubscriptionID]
                   ,[SwitchTo]
                   ,[SwitchStatus]
				   ,[SwitchOrigin]
				   
				)
		SELECT @CustomerSubscriptionID
			,@SwitchToExisting
			,@SwitchStatusCancel
			,@SwitchOrigin
		END

  END
    
 END 


UPDATE tescosubscription.CustomerSubscription 
	SET SubscriptionPlanID=COALESCE(@SubscriptionPlanID,SubscriptionPlanID),
		CustomerPlanStartDate=COALESCE(@CustomerPlanStartDate,CustomerPlanStartDate),
		CustomerPlanEndDate=COALESCE(@CustomerPlanEndDate,CustomerPlanEndDate),
		NextRenewalDate=COALESCE(@NextRenewalDate,NextRenewalDate),
		SubscriptionStatus=COALESCE(@SubscriptionStatus,SubscriptionStatus),
		PaymentProcessStatus=COALESCE(@PaymentProcessStatus,PaymentProcessStatus),
		RenewalReferenceDate=COALESCE(@RenewalReferenceDate,RenewalReferenceDate),  
		UTCUpdatedDateTime=GETUTCDATE() ,
		SwitchTo=Case WHEN @SwitchStatusCancel = 18 THEN NULL ELSE SwitchTo END,
		NextPaymentDate=COALESCE(@NextPaymentDate,NextPaymentDate)
	WHERE CustomerSubscriptionID=@CustomerSubscriptionID
	
	COMMIT TRANSACTION CustomerSubscriptionUpdate
	
 END TRY
	BEGIN CATCH

      SELECT   @errorProcedure       = Routine_Schema  + '.' + Routine_Name
             , @error                = ERROR_NUMBER()
             , @errorDescription     = ERROR_MESSAGE()
             , @errorLine            = ERROR_LINE()
      FROM  INFORMATION_SCHEMA.ROUTINES
      WHERE Routine_Type = 'PROCEDURE' and Routine_Name = OBJECT_NAME(@@PROCID)

     ROLLBACK TRANSACTION CustomerSubscriptionUpdate

      RAISERROR('[Procedure:%s Line:%i Error:%i] %s',16,1,@errorProcedure,@errorLine,@error,@errorDescription)
	END CATCH
END


GO
GRANT EXECUTE ON  [tescosubscription].[CustomerSubscriptionUpdate1] TO [SubsUser]
GO
