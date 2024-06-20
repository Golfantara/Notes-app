package routes

import (
	"notes-app/config"
	"notes-app/features/notes"
	"notes-app/helpers"

	m "notes-app/middlewares"

	"github.com/labstack/echo/v4"
)

func Notess(e *echo.Echo, handler notes.Handler, jwt helpers.JWTInterface, config config.ProgramConfig) {
	notes := e.Group("/notes")

	notes.GET("", handler.GetNotess(), m.AuthorizeJWT(jwt, 3, config.SECRET))
	notes.POST("", handler.CreateNotes(), m.AuthorizeJWT(jwt, 3, config.SECRET))
	
	notes.GET("/:id", handler.NotesDetails(), m.AuthorizeJWT(jwt, 3, config.SECRET))
	notes.PUT("/:id", handler.UpdateNotes(), m.AuthorizeJWT(jwt, 3, config.SECRET))
	notes.DELETE("/:id", handler.DeleteNotes(), m.AuthorizeJWT(jwt, 3, config.SECRET))
}