package dtos

type ResNotes struct {
	ID			int `json:"id"`
	Name 		string `json:"name"`
	UserID 		int `json:"user_id"`
	Description string `json:"description"`
}
