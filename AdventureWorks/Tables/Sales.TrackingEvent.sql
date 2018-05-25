CREATE TABLE [Sales].[TrackingEvent]
(
[TrackingEventID] [int] NOT NULL IDENTITY(1, 1),
[EventName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[TrackingEvent] ADD CONSTRAINT [PK_TrackingEvent_TrackingEventID] PRIMARY KEY CLUSTERED  ([TrackingEventID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracking event lookup table.', 'SCHEMA', N'Sales', 'TABLE', N'TrackingEvent', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tracking event name.', 'SCHEMA', N'Sales', 'TABLE', N'TrackingEvent', 'COLUMN', N'EventName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key.', 'SCHEMA', N'Sales', 'TABLE', N'TrackingEvent', 'COLUMN', N'TrackingEventID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'TrackingEvent', 'CONSTRAINT', N'PK_TrackingEvent_TrackingEventID'
GO
