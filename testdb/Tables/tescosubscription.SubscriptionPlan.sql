CREATE TABLE [tescosubscription].[SubscriptionPlan]
(
[SubscriptionPlanID] [int] NOT NULL IDENTITY(1, 1),
[CountryCurrencyID] [tinyint] NOT NULL,
[BusinessID] [tinyint] NOT NULL,
[SubscriptionID] [tinyint] NOT NULL,
[PlanName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlanDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [smallint] NOT NULL,
[PlanTenure] [int] NOT NULL,
[PlanEffectiveStartDate] [datetime] NOT NULL,
[PlanEffectiveEndDate] [datetime] NOT NULL,
[PlanAmount] [smallmoney] NOT NULL,
[TermConditions] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF_SubscriptionPlan_IsActive] DEFAULT ((1)),
[RecurringMonths] [tinyint] NOT NULL,
[PlanMaxUsage] [smallint] NOT NULL,
[BasketValue] [smallmoney] NOT NULL,
[FreePeriod] [tinyint] NOT NULL,
[IsSlotRestricted] [bit] NOT NULL CONSTRAINT [DF_SubscriptionPlan_IsSlotRestricted] DEFAULT ((0)),
[PaymentInstallmentID] [tinyint] NOT NULL CONSTRAINT [DF_SubscriptionPlan_PaymentInstallmentID] DEFAULT ((1)),
[UTCCreatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_SubscriptionPlan_UTCCreatedDateTime] DEFAULT (getutcdate()),
[UTCUpdatedDateTime] [datetime] NOT NULL CONSTRAINT [DF_SubscriptionPlan_UTCUpdatedDateTime] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[SubscriptionPlan] ADD CONSTRAINT [PK_SubscriptionPlan] PRIMARY KEY CLUSTERED  ([SubscriptionPlanID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NC_SubscriptionPlan_SortOrder] ON [tescosubscription].[SubscriptionPlan] ([SortOrder]) ON [PRIMARY]
GO
ALTER TABLE [tescosubscription].[SubscriptionPlan] ADD CONSTRAINT [UK_SubscriptionPlan_SortOrder] UNIQUE NONCLUSTERED  ([SortOrder]) ON [PRIMARY]
GO
