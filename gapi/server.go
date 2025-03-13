package gapi

import (
	"fmt"
	db "github.com/Kosench/backendBankExample/db/sqlc"
	"github.com/Kosench/backendBankExample/pb"
	"github.com/Kosench/backendBankExample/token"
	"github.com/Kosench/backendBankExample/util"
)

type Server struct {
	pb.UnimplementedSimpleBankServer
	config util.Config
	store  db.Store
	token  token.Maker
}

func NewServer(config util.Config, store db.Store) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	server := &Server{
		config: config,
		store:  store,
		token:  tokenMaker,
	}

	return server, nil
}
