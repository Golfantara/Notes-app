package repository

import (
	"notes-app/features/notes"

	"github.com/labstack/gommon/log"
	"gorm.io/gorm"
)

type model struct {
	db *gorm.DB
}

func New(db *gorm.DB) notes.Repository {
	return &model {
		db: db,
	}
}

func (mdl *model) Paginate(userID, page, size int) []notes.Notes {
	var notes []notes.Notes

	offset := (page - 1) * size

	result := mdl.db.Where("user_id =?", userID).Offset(offset).Limit(size).Find(&notes)
	
	if result.Error != nil {
		log.Error(result.Error)
		return nil
	}

	return notes
}

func (mdl *model) Insert(newNotes notes.Notes) (*notes.Notes, error) {
	result := mdl.db.Create(&newNotes)

	if result.Error != nil {
		log.Error(result.Error)
		return nil, result.Error
	}

	return &newNotes, nil
}

func (mdl *model) SelectByID(notesID int) *notes.Notes {
	var notes notes.Notes
	result := mdl.db.First(&notes, notesID)

	if result.Error != nil {
		log.Error(result.Error)
		return nil
	}

	return &notes
}

func (mdl *model) Update(notes notes.Notes) int64 {
	result := mdl.db.Updates(&notes)

	if result.Error != nil {
		log.Error(result.Error)
	}

	return result.RowsAffected
}

func (mdl *model) DeleteByID(notesID int) int64 {
	result := mdl.db.Delete(&notes.Notes{}, notesID)
	
	if result.Error != nil {
		log.Error(result.Error)
		return 0
	}

	return result.RowsAffected
}

func (mdl *model) GetTotalDataNotes() int64 {
	var totalData int64

	result := mdl.db.Table("notes").Where("deleted_at IS NULL").Count(&totalData)

	if result.Error != nil {
		log.Error(result.Error)
		return 0
	}

	return totalData
}