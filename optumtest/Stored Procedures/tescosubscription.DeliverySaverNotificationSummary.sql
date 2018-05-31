SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [tescosubscription].[DeliverySaverNotificationSummary] 
AS
 
 /*

	Author:			Rangan Thulasi
	Date created:	18 Jan 2012
	Purpose:		
	WarmUP Script:	Execute [tescosubscription].[DeliverySaverNotificationSummary]

	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	27 Jun 2013     Robin                           added new variable and Convert function for planend date

*/

BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE  @CurrentDate DATETIME	
			,@NotifyPeriod TINYINT -- no. of days before which notification has to be sent for expired cards
			,@ActiveSubscriptionStatus TINYINT
			,@RecurringChannelID	TINYINT
			,@SystemFailureStatusID TINYINT
				
			
 
	SELECT  @CurrentDate = GETDATE()	
	       ,@NotifyPeriod = 7
		   ,@ActiveSubscriptionStatus = 8
		   ,@RecurringChannelID = 2	
		   ,@SystemFailureStatusID = 3		   
 --	hard coded values are stored in variables for ease of future changes if any.
	
	SELECT 'Expiry/Payment Reminder' AS MailType
		   ,COUNT(CS.[CustomerSubscriptionID]) MailCount		  
		  
	FROM tescosubscription.CustomerSubscription CS
	WHERE CS.SubscriptionStatus = @ActiveSubscriptionStatus
	AND CS.NextRenewalDate <= DATEADD(DAY, @NotifyPeriod,@CurrentDate)
	AND CS.NextRenewalDate <> CS.EmailSentRenewalDate  --check flag 
	AND CS.NextRenewalDate <  CONVERT(VARCHAR(10),CS.CustomerPlanEndDate,101) -- no notification is needed if the subscription is about to end
	
		 
	UNION
	
	SELECT 'Payment Notification'  AS MailType		 
           ,COUNT(CPH.CustomerPaymentHistoryID)  MailCount		   
	FROM tescosubscription.CustomerPaymentHistoryResponse CPHR
		JOIN tescosubscription.CustomerPaymentHistory CPH ON CPHR.CustomerPaymentHistoryID = CPH.CustomerPaymentHistoryID
			AND CPHR.PaymentStatusID <> @SystemFailureStatusID
			AND IsEmailSent = 0 -- check flag
			AND ChannelID = @RecurringChannelID 
	
END

GO
GRANT EXECUTE ON  [tescosubscription].[DeliverySaverNotificationSummary] TO [SubsUser]
GO
