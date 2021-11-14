package db

import (
	"fmt"
	"os"

	"github.com/alpody/fiber-realworld/model"
	"gorm.io/driver/postgres"
	_ "gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func New() *gorm.DB {
	dsn := "host=/tmp user=realworld dbname=realworld"
	db, err := gorm.Open(postgres.New(postgres.Config{
		DSN: dsn,
		//PreferSimpleProtocol: true, // disables implicit prepared statement usage
	}), &gorm.Config{})

	//db, err := gorm.Open("postgresql", "postgresql://realworld@/realworld?host=/tmp")
	//db, err := gorm.Open("sqlite3", "./database/realworld.db")
	if err != nil {
		fmt.Println("storage err: ", err)
	}
	//db.DB().SetMaxIdleConns(3)
	db.LogMode(true)
	return db
}

func TestDB() *gorm.DB {
	db, err := gorm.Open("sqlite3", "./../database/realworld_test.db")
	if err != nil {
		fmt.Println("storage err: ", err)
	}
	db.DB().SetMaxIdleConns(3)
	db.LogMode(false)
	return db
}

func DropTestDB() error {
	if err := os.Remove("./../database/realworld_test.db"); err != nil {
		return err
	}
	return nil
}

func AutoMigrate(db *gorm.DB) {
	db.AutoMigrate(
		&model.User{},
		&model.Follow{},
		&model.Article{},
		&model.Comment{},
		&model.Tag{},
	)
}
