package mail

import (
	"github.com/Kosench/backendBankExample/util"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestSendEmailWithGmail(t *testing.T) {
	config, err := util.LoadConfig("..")
	require.NoError(t, err)

	sender := NewGmailSender(config.EmailSenderName, config.EmailSenderAddress, config.EmailSenderPassword)

	subject := "A test email"
	content := `
    <h1>Hello world</h1>
    <p>This is a test message from <a href="http://techschool.guru">Tech school</a></p>
	`
	to := []string{"kosenko.id@dvfu.ru"}
	attachFiles := []string{"../README.md"}

	err = sender.SendEmail(subject, content, to, nil, nil, attachFiles)
	require.NoError(t, err)
}
