package handler

import (
	"notes-app/helpers"
	helper "notes-app/helpers"
	"strconv"

	"notes-app/features/notes"
	"notes-app/features/notes/dtos"

	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
)

type controller struct {
	service notes.Usecase
}

func New(service notes.Usecase) notes.Handler {
	return &controller {
		service: service,
	}
}

var validate *validator.Validate

func (ctl *controller) GetNotess() echo.HandlerFunc {
	return func (ctx echo.Context) error  {
		pagination := dtos.Pagination{}
		ctx.Bind(&pagination)
		UserID, ok := ctx.Get("user_id").(int)
		if !ok {
			return ctx.JSON(400, helper.Response("invalid user id"))
		}
		

		if pagination.Page  <= 1 || pagination.Size <= 1 {
			pagination.Page = 1
			pagination.Size = 5
		}

		page := pagination.Page
		size := pagination.Size

		notess, totalData := ctl.service.FindAll(UserID, page, size)

		if len(notess) == 0 {
			return ctx.JSON(404, helper.Response("There is No Notess!"))
		}

		paginationResponse := helpers.PaginationResponse(page, size, int(totalData))

		return ctx.JSON(200, helper.Response("Success!", map[string]any {
			"data": notess,
			"pagination": paginationResponse,
		}))
	}
}


func (ctl *controller) NotesDetails() echo.HandlerFunc {
	return func (ctx echo.Context) error  {
		notesID, err := strconv.Atoi(ctx.Param("id"))

		if err != nil {
			return ctx.JSON(400, helper.Response(err.Error()))
		}

		notes := ctl.service.FindByID(notesID)

		if notes == nil {
			return ctx.JSON(404, helper.Response("Notes Not Found!"))
		}

		return ctx.JSON(200, helper.Response("Success!", map[string]any {
			"data": notes,
		}))
	}
}

func (ctl *controller) CreateNotes() echo.HandlerFunc {
	return func (ctx echo.Context) error  {
		input := dtos.InputNotes{}

		ctx.Bind(&input)
		userID := ctx.Get("user_id").(int)

		validate = validator.New(validator.WithRequiredStructEnabled())

		err := validate.Struct(input)

		if err != nil {
			errMap := helpers.ErrorMapValidation(err)
			return ctx.JSON(400, helper.Response("Bad Request!", map[string]any {
				"error": errMap,
			}))
		}

		notes := ctl.service.Create(input, userID)

		if notes == nil {
			return ctx.JSON(500, helper.Response("Something went Wrong!", nil))
		}

		return ctx.JSON(200, helper.Response("Success!", map[string]any {
			"data": notes,
		}))
	}
}

func (ctl *controller) UpdateNotes() echo.HandlerFunc {
	return func (ctx echo.Context) error {
		input := dtos.InputNotes{}

		notesID, errParam := strconv.Atoi(ctx.Param("id"))

		if errParam != nil {
			return ctx.JSON(400, helper.Response(errParam.Error()))
		}

		notes := ctl.service.FindByID(notesID)

		if notes == nil {
			return ctx.JSON(404, helper.Response("Notes Not Found!"))
		}
		
		ctx.Bind(&input)

		validate = validator.New(validator.WithRequiredStructEnabled())
		err := validate.Struct(input)

		if err != nil {
			errMap := helpers.ErrorMapValidation(err)
			return ctx.JSON(400, helper.Response("Bad Request!", map[string]any {
				"error": errMap,
			}))
		}

		update := ctl.service.Modify(input, notesID)

		if !update {
			return ctx.JSON(500, helper.Response("Something Went Wrong!"))
		}

		return ctx.JSON(200, helper.Response("Notes Success Updated!"))
	}
}

func (ctl *controller) DeleteNotes() echo.HandlerFunc {
	return func (ctx echo.Context) error  {
		notesID, err := strconv.Atoi(ctx.Param("id"))

		if err != nil {
			return ctx.JSON(400, helper.Response(err.Error()))
		}

		notes := ctl.service.FindByID(notesID)

		if notes == nil {
			return ctx.JSON(404, helper.Response("Notes Not Found!"))
		}

		delete := ctl.service.Remove(notesID)

		if !delete {
			return ctx.JSON(500, helper.Response("Something Went Wrong!"))
		}

		return ctx.JSON(200, helper.Response("Notes Success Deleted!", nil))
	}
}
