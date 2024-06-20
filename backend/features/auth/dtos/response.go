package dtos

import "notes-app/features/notes"

type ResUser struct {
	ID       int    `json:"id"`
	RoleID   int    `json:"role_id"`
	Username string `json:"username"`
	Fullname string `json:"fullname"`

	Notes []notes.Notes
}

type LoginResponse struct {
	Username     string `json:"username"`
	Fullname     string `json:"fullname"`
	RoleID       int    `json:"role_id"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

type ResJWT struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}