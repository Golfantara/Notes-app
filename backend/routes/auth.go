package routes

import (
	"notes-app/config"
	"notes-app/features/auth"
	"notes-app/helpers"

	m "notes-app/middlewares"

	"github.com/labstack/echo/v4"
)

func Auth(e *echo.Echo, handler auth.Handler, jwt helpers.JWTInterface, config config.ProgramConfig){
	auth := e.Group("/auth")
	auth.POST("/register", handler.RegisterUser())
	auth.POST("/login", handler.Login())
	auth.POST("/refresh-jwt", handler.RefreshJWT(), m.AuthorizeJWT(jwt, 3, config.SECRET) )
	auth.GET("/me", handler.MyProfile(), m.AuthorizeJWT(jwt, 3, config.SECRET))
}