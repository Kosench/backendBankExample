package db

import (
	"context"
	"database/sql"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Store interface {
	Querier
	TransferTx(ctx context.Context, arg TransferTxParams) (TransferTxResult, error)
	CreateUserTx(ctx context.Context, arg CreateUserTxParams) (CreateUserTxResult, error)
	VerifyEmailTx(ctx context.Context, arg VerifyEmailTxParams) (VerifyEmailTxResult, error)
}

type TxOptions struct {
	Isolation sql.IsolationLevel
	ReadOnly  bool
}

type TransferTxParams struct {
	FromAccountID int64 `json:"from_account_id"`
	ToAccountID   int64 `json:"to_account_id"`
	Amount        int64 `json:"amount"`
}

type TransferTxResult struct {
	Transfer    Transfer `json:"transfer"`
	FromAccount Account  `json:"from_account"`
	ToAccount   Account  `json:"to_account"`
	FromEntry   Entry    `json:"from_entry"`
	ToEntry     Entry    `json:"to_entry"`
}

type SQLStore struct {
	*Queries
	connPool *pgxpool.Pool
}

func NewStore(connPool *pgxpool.Pool) *SQLStore {
	return &SQLStore{
		connPool: connPool,
		Queries:  New(connPool),
	}
}

func (store *SQLStore) TransferTx(ctx context.Context, arg TransferTxParams) (TransferTxResult, error) {
	var result TransferTxResult

	err := store.execTx(ctx, func(q *Queries) error {
		var err error

		result.Transfer, err = q.CreateTransfer(ctx, CreateTransferParams{
			FromAccountID: arg.FromAccountID,
			ToAccountID:   arg.ToAccountID,
			Amount:        arg.Amount,
		})
		if err != nil {
			return err
		}

		result.FromEntry, err = q.CreateEntry(ctx, CreateEntryParams{
			AccountID: arg.FromAccountID,
			Amount:    -arg.Amount,
		})
		if err != nil {
			return err
		}

		result.ToEntry, err = q.CreateEntry(ctx, CreateEntryParams{
			AccountID: arg.ToAccountID,
			Amount:    arg.Amount,
		})
		if err != nil {
			return err
		}

		if arg.FromAccountID < arg.ToAccountID {
			result.FromAccount, result.ToAccount, err = updateBalances(
				ctx,
				q,
				arg.FromAccountID,
				-arg.Amount,
				arg.ToAccountID,
				arg.Amount)
		} else {
			result.ToAccount, result.FromAccount, err = updateBalances(
				ctx,
				q,
				arg.ToAccountID,
				arg.Amount,
				arg.FromAccountID,
				-arg.Amount)
		}

		return nil

	})

	return result, err
}

func updateBalances(
	ctx context.Context,
	queries *Queries,
	accountID_1 int64,
	amount_1 int64,
	accountID_2 int64,
	amount_2 int64,
) (account1, account2 Account, err error) {
	account1, err = queries.AddAccountBalance(ctx, AddAccountBalanceParams{
		Amount: amount_1,
		ID:     accountID_1,
	})
	if err != nil {
		return
	}

	account2, err = queries.AddAccountBalance(ctx, AddAccountBalanceParams{
		ID:     accountID_2,
		Amount: amount_2,
	})
	if err != nil {
		return
	}

	return
}
