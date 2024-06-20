package main

import (
	"fmt"
	"net/http"
	"notes-app/config"
	"notes-app/features/auth"
	"notes-app/features/notes"
	"notes-app/helpers"
	"notes-app/middlewares"
	"notes-app/routes"
	"notes-app/utils"

	"github.com/labstack/echo/v4"

	ah "notes-app/features/auth/handler"
	ar "notes-app/features/auth/repository"
	au "notes-app/features/auth/usecase"

	nh "notes-app/features/notes/handler"
	nr "notes-app/features/notes/repository"
	nu "notes-app/features/notes/usecase"
)

func main() {
	e := echo.New()
	cfg := config.InitConfig()
	jwtService := helpers.NewJWT(*cfg)
	
	middlewares.LogMiddlewares(e)
	routes.Auth(e, AuthHandler(), jwtService, *cfg)
	routes.Notess(e, NotesHandler(), jwtService, *cfg)

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello anjay mabar!")
	})
	e.Start(fmt.Sprintf(":%s", cfg.SERVER_PORT))
}

func AuthHandler() auth.Handler{
	config := config.InitConfig()

	db := utils.InitDB()
	jwt := helpers.NewJWT(*config)
	hash := helpers.NewHash()
	validation := helpers.NewValidationRequest()

	repo := ar.New(db)
	ac := au.New(repo, jwt, hash, validation)
	return ah.New(ac)
}

func NotesHandler() notes.Handler {
	db := utils.InitDB()
	repo := nr.New(db)
	nc := nu.New(repo)
	return nh.New(nc)
}