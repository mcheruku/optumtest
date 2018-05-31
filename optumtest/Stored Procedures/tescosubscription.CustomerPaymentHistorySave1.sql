SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [tescosubscription].[CustomerPaymentHistorySave1]
(
		--INPUT PARAMETERS HERE--
	 @CustomerPaymentID				BIGINT
	,@CustomerSubscriptionID		BIGINT
    ,@PaymentAmount					SMALLMONEY
	,@Channel						VARCHAR(20) 
	,@PackageExecutionHistoryId		BIGINT
	,@IsPreAuth						Bit
)
AS

/*

	Author:			Robin
	Date created:	20 Jun 2014
	Purpose:		To insert the status of the payment for each payment record in table CustomerPaymentHistory
	Behaviour:		This procedure is called from Appstore on receiving response from CPS
	Usage:			Often in batch
	Called by:		AppStore
	WarmUP Script:	 
	--Modifications History--
	Changed On		Changed By		Defect Ref		Change Description
	<dd Mmm YYYY>	<Dev Name>		<TFS no.>		<Summary of changes>
	
*/

BEGIN
	DECLARE @ChannelID							TINYINT
			,@CurrentDate						DATETIME
				
	SET NOCOUNT ON

	SELECT @CurrentDate = GETDATE()
		   ,@ChannelID=ChannelID 
    FROM tescosubscription.ChannelMaster WITH (NOLOCK) WHERE ChannelName=@Channel

		
		INSERT	INTO tescosubscription.CustomerPaymentHistory 
			(
				[CustomerPaymentID]
			   ,[CustomerSubscriptionID]  
			   ,[PaymentDate]
			   ,[PaymentAmount]
			   ,[ChannelID]
				,[PackageExecutionHistoryId]
				,[IsPreAuth]
			) output INSERTED.CustomerPaymentHistoryid 
			
		VALUES	( 
				@CustomerPaymentID, 
				@CustomerSubscriptionID, 
		        @CurrentDate, 
		        @PaymentAmount, 
		        @ChannelID,
				case when @PackageExecutionHistoryId <= 0 then null	else @PackageExecutionHistoryId end,
				@IsPreAuth
			)
END

GO
GRANT EXECUTE ON  [tescosubscription].[CustomerPaymentHistorySave1] TO [SubsUser]
GO
