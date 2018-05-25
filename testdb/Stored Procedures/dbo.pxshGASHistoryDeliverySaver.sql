SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	

CREATE PROCEDURE [dbo].[pxshGASHistoryDeliverySaver]      
(      
@branchlist  varchar(2000)= null      
)      
      
AS      
    
SELECT  CASE   
  WHEN SubscriptionPlanID = 1 THEN '3 Month Plan'    
  WHEN SubscriptionPlanID = 2 THEN '6 Month Plan'   
  WHEN SubscriptionPlanID = 5 THEN '3 Month Midweek Plan'   
  WHEN SubscriptionPlanID = 6 THEN '6 Month Midweek Plan'   
  END as software,    
    convert(char(11),CustomerPlanStartDate, 112) as orderdate,    
      datepart(hh, CustomerPlanStartDate) as orderhour,count(*) as orders    
 FROM [tescosubscription].[CustomerSubscription] (nolock)    
Where [SubscriptionStatus] = 8    
and CustomerPlanStartDate between dateadd(dd, -15, getdate()) and getdate()    
and SwitchCustomerSubscriptionID IS NULL
group by    
  SubscriptionPlanID, convert(char(11),CustomerPlanStartDate, 112) ,datepart(hh, CustomerPlanStartDate)
  order by software DESC, orderdate, orderhour      
        
        
GO
