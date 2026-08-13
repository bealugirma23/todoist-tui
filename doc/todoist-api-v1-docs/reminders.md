# Reminders & Notification Settings

Availability of reminders depends on the user's Todoist plan.

## GET /reminders

List reminders.

```http
GET /api/v1/reminders
```

## GET /reminders/{reminder_id}

Get one reminder.

```http
GET /api/v1/reminders/{reminder_id}
```

## POST /reminders/{reminder_id}

Update a reminder.

```http
POST /api/v1/reminders/{reminder_id}
```

Fields include:

- `minute_offset`
- `due`
- `service`
- `is_urgent`

## DELETE /reminders/{reminder_id}

Delete a reminder.

```http
DELETE /api/v1/reminders/{reminder_id}
```

## PUT /notification_setting

Update a notification setting.

```http
PUT /api/v1/notification_setting
```

Body:

- `notification_type`
- `service`
- `dont_notify`
