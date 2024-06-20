package notes

import (
	"notes-app/features/notes/dtos"

	"github.com/labstack/echo/v4"
)

type Repository interface {
	Paginate(userID, page, size int) []Notes
	Insert(newNotes Notes) (*Notes, error)
	SelectByID(notesID int) *Notes
	Update(notes Notes) int64
	DeleteByID(notesID int) int64
}

type Usecase interface {
	FindAll(userID, page, size int) []dtos.ResNotes
	FindByID(notesID int) *dtos.ResNotes
	Create(newNotes dtos.InputNotes, UserID int) *dtos.ResNotes
	Modify(notesData dtos.InputNotes, notesID int) bool
	Remove(notesID int) bool
}

type Handler interface {
	GetNotess() echo.HandlerFunc
	NotesDetails() echo.HandlerFunc
	CreateNotes() echo.HandlerFunc
	UpdateNotes() echo.HandlerFunc
	DeleteNotes() echo.HandlerFunc
}
