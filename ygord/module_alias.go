// Copyright 2014, Truveris Inc. All Rights Reserved.
// Use of this source code is governed by the ISC license in the LICENSE file.
//
// This module allows channel users to configure aliases themselves.

package main

import (
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"
	"math/rand"

	"github.com/truveris/ygor"
)

const (
	// That should be plenty for most IRC servers to handle.
	MaxCharsPerPage = 444

	// You can't list that many aliases without trouble...
	MaxAliasesForFullList = 40

	// We should stop at cat999.
	MaxAliasIncrements = 1000
)

// Given an alias name, return a new name with increment if the name contains
// the '#' rune.
func GetIncrementedName(name string) (string, error) {
	cnt := strings.Count(name, "#")
	if cnt == 0 {
		return name, nil
	} else if cnt > 1 {
		return "", errors.New("too many '#'")
	}

	var newName string

	for i := 1; i < MaxAliasIncrements; i++ {
		newName = strings.Replace(name, "#", fmt.Sprintf("%d", i), 1)

		if Aliases.Get(newName) == nil {
			break
		}
	}

	return newName, nil
}

type AliasModule struct{}

func (module AliasModule) PrivMsg(msg *ygor.PrivMsg) {}

// Command used to set a new alias.
func (module *AliasModule) AliasCmdFunc(msg *ygor.Message) {
	var outputMsg string

	if len(msg.Args) == 0 {
		IRCPrivMsg(msg.ReplyTo, "usage: alias name [command [params ...]]")
		return
	}

	name := msg.Args[0]
	alias := Aliases.Get(name)

	// Request the value of an alias.
	if len(msg.Args) == 1 {
		if alias == nil {
			IRCPrivMsg(msg.ReplyTo, "error: unknown alias")
			return
		}
		IRCPrivMsg(msg.ReplyTo, fmt.Sprintf("'%s' is an alias for '%s'",
			alias.Name, alias.Value))
		return
	}

	// Set a new alias.
	cmd := ygor.GetCommand(name)
	if cmd != nil {
		IRCPrivMsg(msg.ReplyTo, fmt.Sprintf("error: '%s' is already a"+
			" command", name))
		return
	}

	newValue := strings.Join(msg.Args[1:], " ")

	if alias == nil {
		newName, err := GetIncrementedName(name)
		if err != nil {
			IRCPrivMsg(msg.ReplyTo, "error: " + err.Error())
			return
		}
		if newName != name {
			outputMsg = "ok (created as \"" + newName + "\")"
		} else {
			outputMsg = "ok (created)"
		}
		Aliases.Add(newName, newValue)
	} else if alias.Value == newValue {
		outputMsg = "no changes"
	} else {
		outputMsg = "ok (replaces \"" + alias.Value + "\")"
		alias.Value = newValue
	}

	err := Aliases.Save()
	if err != nil {
		outputMsg = "error: " + err.Error()
	}

	IRCPrivMsg(msg.ReplyTo, outputMsg)
}

// Take a list of aliases, return joined pages.
func getPagesOfAliases(aliases []string) []string {
	length := 0
	pages := make([]string, 0)

	for i := 0; i < len(aliases); {
		var page []string

		if length > 0 {
			length += len(", ")
		}

		length += len(aliases[i])

		if length > MaxCharsPerPage {
			page, aliases = aliases[:i], aliases[i:]
			pages = append(pages, strings.Join(page, ", "))
			length = 0
			i = 0
			continue
		}

		i++
	}

	if length > 0 {
		pages = append(pages, strings.Join(aliases, ", "))
	}

	return pages
}

func (module *AliasModule) UnAliasCmdFunc(msg *ygor.Message) {
	if len(msg.Args) != 1 {
		IRCPrivMsg(msg.ReplyTo, "usage: unalias name")
		return
	}

	name := msg.Args[0]
	alias := Aliases.Get(name)

	if alias == nil {
		IRCPrivMsg(msg.ReplyTo, "error: unknown alias")
		return
	} else {
		Aliases.Delete(name)
		IRCPrivMsg(msg.ReplyTo, "ok (deleted)")
	}
	Aliases.Save()
}

func (module *AliasModule) AliasesCmdFunc(msg *ygor.Message) {
	if len(msg.Args) != 0 {
		IRCPrivMsg(msg.ReplyTo, "usage: aliases")
		return
	}

	aliases := Aliases.Names()

	if len(aliases) > MaxAliasesForFullList {
		IRCPrivMsg(msg.ReplyTo, "error: too many results, use grep")
		return
	}

	sort.Strings(aliases)
	first := true
	for _, page := range getPagesOfAliases(aliases) {
		if first {
			IRCPrivMsg(msg.ReplyTo, "known aliases: "+page)
			first = false
		} else {
			IRCPrivMsg(msg.ReplyTo, "... "+page)
		}
		if !cfg.TestMode {
			time.Sleep(500 * time.Millisecond)
		}
	}
}

func (module *AliasModule) GrepCmdFunc(msg *ygor.Message) {
	if len(msg.Args) != 1 {
		IRCPrivMsg(msg.ReplyTo, "usage: grep pattern")
		return
	}

	results := Aliases.Find(msg.Args[0])
	sort.Strings(results)

	if len(results) == 0 {
		IRCPrivMsg(msg.ReplyTo, "error: no results")
		return
	}

	found := strings.Join(results, ", ")
	if len(found) > MaxCharsPerPage {
		IRCPrivMsg(msg.ReplyTo, "error: too many results, refine your search")
		return
	}

	IRCPrivMsg(msg.ReplyTo, found)
}

func (module *AliasModule) RandomCmdFunc(msg *ygor.Message) {
	var names []string

	switch len(msg.Args) {
	case 0:
		names = Aliases.Names()
	case 1:
		names = Aliases.Find(msg.Args[0])
	default:
		IRCPrivMsg(msg.ReplyTo, "usage: random [pattern]")
		return
	}

	if len(names) <= 0 {
		IRCPrivMsg(msg.ReplyTo, "no matches found")
		return
	}

	idx := rand.Intn(len(names))

	body, err := Aliases.Resolve(names[idx])
	if err != nil {
		IRCPrivMsg(msg.ReplyTo, "failed to resolve aliases: " +
			err.Error())
		return
	}

	newmsgs, err := NewMessagesFromBody(body)
	if err != nil {
		IRCPrivMsg(msg.ReplyTo, "error: failed to expand chose alias '" +
			names[idx] + "': " + err.Error())
		return
	}

	IRCPrivMsg(msg.ReplyTo, "the codes have chosen "+names[idx])

	for _, newmsg := range newmsgs {
		newmsg.ReplyTo = msg.ReplyTo
		newmsg.Type = msg.Type
		newmsg.UserID = msg.UserID
		newmsg.ReplyTo = msg.ReplyTo
		if newmsg == nil {
			Debug("failed to convert PRIVMSG")
			return
		}
		InputQueue <- newmsg
	}
}

func (module *AliasModule) Init() {
	ygor.RegisterCommand(ygor.Command{
		Name:            "alias",
		PrivMsgFunction: module.AliasCmdFunc,
		Addressed:       true,
		AllowPrivate:    false,
		AllowChannel:    true,
	})

	ygor.RegisterCommand(ygor.Command{
		Name:            "grep",
		PrivMsgFunction: module.GrepCmdFunc,
		Addressed:       true,
		AllowPrivate:    false,
		AllowChannel:    true,
	})

	ygor.RegisterCommand(ygor.Command{
		Name:            "random",
		PrivMsgFunction: module.RandomCmdFunc,
		Addressed:       true,
		AllowPrivate:    false,
		AllowChannel:    true,
	})

	ygor.RegisterCommand(ygor.Command{
		Name:            "unalias",
		PrivMsgFunction: module.UnAliasCmdFunc,
		Addressed:       true,
		AllowPrivate:    false,
		AllowChannel:    true,
	})

	ygor.RegisterCommand(ygor.Command{
		Name:            "aliases",
		PrivMsgFunction: module.AliasesCmdFunc,
		Addressed:       true,
		AllowPrivate:    true,
		AllowChannel:    true,
	})
}
