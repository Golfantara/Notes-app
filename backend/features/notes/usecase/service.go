package usecase

import (
	"notes-app/features/notes"
	"notes-app/features/notes/dtos"

	"github.com/labstack/gommon/log"
	"github.com/mashingan/smapping"
)

type service struct {
	model notes.Repository
}

func New(model notes.Repository) notes.Usecase {
	return &service {
		model: model,
	}
}

func (svc *service) FindAll(userID, page, size int) []dtos.ResNotes {
	var notess []dtos.ResNotes

	notessEnt := svc.model.Paginate(userID, page, size)

	for _, notes := range notessEnt {
		var data dtos.ResNotes

		if err := smapping.FillStruct(&data, smapping.MapFields(notes)); err != nil {
			log.Error(err.Error())
		} 
		
		notess = append(notess, data)
	}

	return notess
}

func (svc *service) FindByID(notesID int) *dtos.ResNotes {
	res := dtos.ResNotes{}
	notes := svc.model.SelectByID(notesID)

	if notes == nil {
		return nil
	}

	err := smapping.FillStruct(&res, smapping.MapFields(notes))
	if err != nil {
		log.Error(err)
		return nil
	}

	return &res
}

func (svc *service) Create(newNotes dtos.InputNotes, UserID int) *dtos.ResNotes {
	notes := notes.Notes{}
	
	err := smapping.FillStruct(&notes, smapping.MapFields(newNotes))
	if err != nil {
		log.Error(err)
		return nil
	}

	notes.UserID = UserID
	result, err := svc.model.Insert(notes)
	if err != nil {
		log.Error(err)
		return nil
	}

	resNotes := dtos.ResNotes{}
	resNotes.UserID = result.UserID
	resNotes.ID = result.ID
	errRes := smapping.FillStruct(&resNotes, smapping.MapFields(newNotes))
	if errRes != nil {
		log.Error(errRes)
		return nil
	}

	return &resNotes
}

func (svc *service) Modify(notesData dtos.InputNotes, notesID int) bool {
	newNotes := notes.Notes{}

	err := smapping.FillStruct(&newNotes, smapping.MapFields(notesData))
	if err != nil {
		log.Error(err)
		return false
	}

	newNotes.ID = notesID
	rowsAffected := svc.model.Update(newNotes)

	if rowsAffected <= 0 {
		log.Error("There is No Notes Updated!")
		return false
	}
	
	return true
}

func (svc *service) Remove(notesID int) bool {
	rowsAffected := svc.model.DeleteByID(notesID)

	if rowsAffected <= 0 {
		log.Error("There is No Notes Deleted!")
		return false
	}

	return true
}