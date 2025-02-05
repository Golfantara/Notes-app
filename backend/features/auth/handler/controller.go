package handler

import (
	"notes-app/features/auth"
	"notes-app/features/auth/dtos"
	"notes-app/helpers"

	"github.com/labstack/echo/v4"
)

type controller struct {
	service auth.Usecase
}

func New(service auth.Usecase) auth.Handler {
	return &controller{
		service: service,
	}
}

func (ctl *controller) RegisterUser() echo.HandlerFunc {
	return func(ctx echo.Context) error {
		input := dtos.InputUser{}

		ctx.Bind(&input)

		user, errMap, err := ctl.service.Register(input)
		if errMap != nil {
			return ctx.JSON(400, helpers.Response("missing some data", map[string]any{
				"error": errMap,
			}))
		}

		if err != nil {
			return ctx.JSON(400, helpers.Response("bad request", map[string]any{
				"error": err.Error(),
			}))
		}

		return ctx.JSON(200, helpers.Response("success", map[string]any{
			"data": user,
		}))
	}
}

func (ctl *controller) Login() echo.HandlerFunc {
	return func(ctx echo.Context) error {
		loginData := dtos.RequestLogin{}

		if err := ctx.Bind(&loginData); err != nil {
			return ctx.JSON(400, helpers.Response("invalid request body"))
		}

		loginRes, errMap, err := ctl.service.Login(loginData)
		if errMap != nil {
			return ctx.JSON(400, helpers.Response("missing some data", map[string]any{
				"error": errMap,
			}))
		}
		
		
		if err != nil {
			return ctx.JSON(401, helpers.Response(err.Error()))
		}

		return ctx.JSON(200, helpers.Response("success", map[string]any{
			"data": loginRes,
		}))
	}
}

func (ctl *controller) RefreshJWT() echo.HandlerFunc {
	return func(ctx echo.Context) error {
		jwt := dtos.RefreshJWT{}
		ctx.Bind(&jwt)

		refershJWT, err := ctl.service.RefreshJWT(jwt)
		if err != nil {
			if err.Error() == "validate token failed" {
				return ctx.JSON(400, helpers.Response("invalid jwt token"))
			}

			return ctx.JSON(500, helpers.Response("something went wrong"))
		}

		return ctx.JSON(200, helpers.Response("success", map[string]any{
			"data": refershJWT,
		}))
	}
}

func (ctl *controller) MyProfile() echo.HandlerFunc {
	return func(ctx echo.Context) error {
		userID := ctx.Get("user_id").(int)

		user := ctl.service.MyProfile(userID)
		if user == nil {
			return ctx.JSON(404, helpers.Response("user not found"))
		}
		
		return ctx.JSON(200, helpers.Response("succes", map[string]any{
			"data": user,
		}))
	}
}