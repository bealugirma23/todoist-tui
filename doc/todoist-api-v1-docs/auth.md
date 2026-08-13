# Authentication & Token Management

## OAuth authorization

These OAuth endpoints are hosted outside `/api/v1`.

### Authorize

```http
GET https://app.todoist.com/oauth/authorize
```

Main parameters:

- `client_id` — required
- `scope` — required
- `state` — required
- `redirect_uri` — required when multiple redirect URIs are configured
- `response_type` — normally `code`

### Exchange authorization code

```http
POST https://api.todoist.com/oauth/access_token
```

Main parameters:

- `client_id`
- `client_secret` — for confidential clients
- `code`
- `redirect_uri` where applicable

### Refresh access token

```http
POST https://api.todoist.com/oauth/access_token
```

Use:

- `grant_type=refresh_token`
- `refresh_token`
- `client_id`
- `client_secret` for confidential clients

## API v1 token endpoints

### Migrate Personal Token

```http
POST /api/v1/access_tokens/migrate_personal_token
```

Body:

```json
{
  "client_id": "CLIENT_ID",
  "client_secret": "CLIENT_SECRET",
  "personal_token": "PERSONAL_TOKEN",
  "scope": "data:read_write"
}
```

### Revoke Access Token

```http
DELETE /api/v1/access_tokens
```

Query parameters:

- `client_id` — required
- `client_secret` — required
- `access_token` — required

### RFC 7009 token revocation

```http
POST /api/v1/revoke
```

Uses form/application data and HTTP Basic client authentication.

Body:

```json
{
  "token": "ACCESS_TOKEN",
  "token_type_hint": "access_token"
}
```
