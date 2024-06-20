package notes

import (
	"gorm.io/gorm"
)

type Notes struct {
	gorm.Model

	ID int `gorm:"type:int(11)"`
	UserID      int     `gorm:"type:int(11)"`
	Name string `gorm:"type:varchar(255)"`
	Description string `gorm:"type:varchar(255)"`
}

