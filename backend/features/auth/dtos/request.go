package dtos

type RequestLogin struct {
	Username string `json:"username" form:"username" validate:"required"`
	Password string `json:"password" form:"password" validate:"required,min=8"`
}

type InputUser struct {
	Username string `json:"username" form:"username" validate:"required"`
	Fullname string `json:"fullname" form:"fullname"`
	Password string `json:"password" form:"password" validate:"required,alphanum,min=8"`
}

type RefreshJWT struct {
	RefreshToken string `json:"refresh_token" form:"refresh_token" validate:"required"`
}