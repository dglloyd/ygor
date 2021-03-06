#!/bin/sh
#
# Tests in this file are separated by two blank lines. Each test is
# self-sufficient and should cleanup after itself (use the cleanup function).
# No state should be maintained between each.
#

. ./_functions.sh

cleanup


announce "turret usage (empty)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: turret"
cat > test.expected <<EOF
PRIVMSG #test :usage: turret command [param]
EOF
assert_output && pass
cleanup


announce "turret usage (too many)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: turret jimmy foo bar"
cat > test.expected <<EOF
PRIVMSG #test :usage: turret command [param]
EOF
assert_output && pass
cleanup


announce "turret reset"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: turret reset"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 turret reset
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 turret reset
EOF
assert_output && pass
cleanup


announce "turret fire 4"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: turret fire 4"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 turret fire 4
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 turret fire 4
EOF
assert_output && pass
cleanup


announce "volume usage"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: volume"
cat > test.expected <<EOF
PRIVMSG #test :usage: volume percent
EOF
assert_output && pass
cleanup


announce "volume 50%"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: volume 50%"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 volume 50%
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 volume 50%
EOF
assert_output && pass
cleanup


announce "volume -10%"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: volume -10%"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 volume -10%
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 volume -10%
EOF
assert_output && pass
cleanup


announce "volume error"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
test_line "minion user_id_1234567891 volume error things"
cat > test.expected <<EOF
PRIVMSG #test :volume@pi2: error things
EOF
assert_output && pass
cleanup


announce "unknown chatter"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :blabla"
cat > test.expected <<EOF
EOF
assert_output && pass
cleanup


announce "unhandled command (channel)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: wtf"
cat > test.expected <<EOF
PRIVMSG #test :command not found: wtf
EOF
assert_output && pass
cleanup


announce "unhandled command (private prefixed)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG whygore :whygore: wtf"
cat > test.expected <<EOF
PRIVMSG jimmy :command not found: wtf
EOF
assert_output && pass
cleanup


announce "unhandled command (private no prefix)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG whygore :wtf"
cat > test.expected <<EOF
PRIVMSG jimmy :command not found: wtf
EOF
assert_output && pass
cleanup


announce "nop"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: nop"
cat > test.expected <<EOF
EOF
assert_output && pass
cleanup


announce "multi-commands"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: wtf; nop;bbq"
cat > test.expected <<EOF
PRIVMSG #test :command not found: wtf
PRIVMSG #test :command not found: bbq
EOF
assert_output && pass
cleanup


announce "commands"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: commands"
cat > test.expected <<EOF
PRIVMSG #test :alias, aliases, commands, grep, image, minions, nop, ping, play, random, reboot, say, shutup, skip, turret, unalias, volume, web, xombrero
EOF
assert_output && pass
cleanup


announce "minion registration"
test_line "minion user_id_0123456789 register bobert-von-cheesecake https://nom.nom/super-train/"
cat > test.expected <<EOF
[SQS-SendToMinion] https://nom.nom/super-train/ register success
EOF
assert_output && pass
cleanup


announce "minions list"
test_line "minion user_id_1234567890 register bobert-von-cheesecake https://nom.nom/super-train/bobert"
test_line "minion user_id_0987654321 register jo-mac-whopper https://nom.nom/super-train/jo"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: minions"
cat > test.expected <<EOF
PRIVMSG #test :currently registered: bobert-von-cheesecake, jo-mac-whopper
EOF
assert_output && pass
cleanup


announce "talk to the bot without colon"
test_line "minion user_id_1234567890 register bobert-von-cheesecake https://nom.nom/super-train/bobert"
test_line "minion user_id_0987654321 register jo-mac-whopper https://nom.nom/super-train/jo"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore minions"
cat > test.expected <<EOF
PRIVMSG #test :currently registered: bobert-von-cheesecake, jo-mac-whopper
EOF
assert_output && pass
cleanup


announce "talk to the bot without space"
test_line "minion user_id_1234567890 register bobert-von-cheesecake https://nom.nom/super-train/bobert"
test_line "minion user_id_0987654321 register jo-mac-whopper https://nom.nom/super-train/jo"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore:minions"
cat > test.expected <<EOF
PRIVMSG #test :currently registered: bobert-von-cheesecake, jo-mac-whopper
EOF
assert_output && pass
cleanup


announce "spaces everywhere"
test_line "minion user_id_1234567890 register bobert-von-cheesecake https://nom.nom/super-train/bobert"
test_line "minion user_id_0987654321 register jo-mac-whopper https://nom.nom/super-train/jo"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :  whygore  minions  "
cat > test.expected <<EOF
PRIVMSG #test :currently registered: bobert-von-cheesecake, jo-mac-whopper
EOF
assert_output && pass
cleanup


announce "ping minions (outgoing)"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: ping"
cat > test.expected <<EOF
[SQS-SendToMinion] https://nom.nom/super-train/bobert ping 1136239445000000000
[SQS-SendToMinion] https://nom.nom/super-train/jo ping 1136239445000000000
PRIVMSG #ygor :sent to pi1: ping 1136239445000000000
PRIVMSG #ygor :sent to pi2: ping 1136239445000000000
EOF
assert_output && pass
cleanup


announce "ping minions (late response)"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
{
	sleep 0.1
	echo "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: ping"
	sleep 0.1
	echo "minion user_id_1234567890 pong 1136239945000000000"
	sleep 0.2
} | test_input
cat > test.expected <<EOF
[SQS-SendToMinion] https://nom.nom/super-train/bobert ping 1136239445000000000
[SQS-SendToMinion] https://nom.nom/super-train/jo ping 1136239445000000000
PRIVMSG #ygor :sent to pi1: ping 1136239445000000000
PRIVMSG #ygor :sent to pi2: ping 1136239445000000000
PRIVMSG #ygor :pong: got old ping reponse (1136239945000000000)
EOF
assert_output && pass
cleanup


announce "ping minions (good response)"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
{
	echo "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: ping"
	sleep 0.2
	echo "minion user_id_1234567890 pong 1136239445000000000"
	sleep 0.2
	echo "minion user_id_1234567891 pong 1136239445000000000"
	sleep 0.2
} | test_input
sed 's/[0-9]*h[0-9]*m[0-9.]*s/timestamp/' test.output > test.tmp
mv test.tmp test.output
cat > test.expected <<EOF
[SQS-SendToMinion] https://nom.nom/super-train/bobert ping 1136239445000000000
[SQS-SendToMinion] https://nom.nom/super-train/jo ping 1136239445000000000
PRIVMSG #ygor :sent to pi1: ping 1136239445000000000
PRIVMSG #ygor :sent to pi2: ping 1136239445000000000
PRIVMSG #test :delay with pi1: timestamp
PRIVMSG #test :delay with pi2: timestamp
EOF
assert_output && pass
cleanup


announce "play"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: play stuff.ogg"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play stuff.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play stuff.ogg
EOF
assert_output && pass
cleanup


announce "play w/ duration"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: play stuff.ogg 5s"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play stuff.ogg 5s
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play stuff.ogg 5s
EOF
assert_output && pass
cleanup


announce "set a new alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
cat > test.expected <<EOF
PRIVMSG #test :ok (created)
EOF
assert_output && pass
cleanup


announce "set an incremental alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias cat# play stuff1.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias cat# play stuff2.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias cat# play stuff3.ogg"
cat > test.expected <<EOF
PRIVMSG #test :ok (created as "cat3")
EOF
assert_output && pass
cleanup


announce "set an incremental alias (error)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias cat## play stuff.ogg"
cat > test.expected <<EOF
PRIVMSG #test :error: too many '#'
EOF
assert_output && pass
cleanup


announce "set an incremental alias (already exist)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias dog# play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias dog# play stuff.ogg"
cat > test.expected <<EOF
PRIVMSG #test :error: already exists as 'dog1'
EOF
assert_output && pass
cleanup


announce "set a new nested alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble blabla 8s"
cat > test.expected <<EOF
PRIVMSG #test :ok (created)
EOF
assert_output && pass
cleanup


announce "set a new alias (permission error)"
touch test.aliases
chmod 000 test.aliases
test_line_error "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
cat > test.expected <<EOF
EOF
assert_output || fail
cat > test.expected <<EOF
alias file error: open test.aliases: permission denied
EOF
assert_stderr && pass
cleanup


announce "set an alias with a colon"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias :) play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: :)"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play stuff.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play stuff.ogg
EOF
assert_output && pass
cleanup


announce "get this new alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla"
cat > test.expected <<EOF
PRIVMSG #test :blabla="play stuff.ogg" (created by jimmy on 2000-01-01T00:00:00Z)
EOF
assert_output && pass
cleanup


announce "get a nested alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble blabla 8s"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble"
cat > test.expected <<EOF
PRIVMSG #test :babble="blabla 8s" (created by jimmy on 2000-01-01T00:00:00Z)
EOF
assert_output && pass
cleanup


announce "change this alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play things.ogg"
cat > test.expected <<EOF
PRIVMSG #test :ok (replaces "play stuff.ogg")
EOF
assert_output && pass
cleanup


announce "unchanged alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
cat > test.expected <<EOF
PRIVMSG #test :no changes
EOF
assert_output && pass
cleanup


announce "get this updated alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play things.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla"
cat > test.expected <<EOF
PRIVMSG #test :blabla="play things.ogg" (created by jimmy on 2000-01-01T00:00:00Z)
EOF
assert_output && pass
cleanup


announce "get unknown alias (empty registry)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias whatevs"
cat > test.expected <<EOF
PRIVMSG #test :error: unknown alias
EOF
assert_output && pass
cleanup


announce "get unknown alias (non-empty registry)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias things play things.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias whatevs"
cat > test.expected <<EOF
PRIVMSG #test :error: unknown alias
EOF
assert_output && pass
cleanup


announce "use a nested alias"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble blabla 8s"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: babble"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play stuff.ogg 8s
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play stuff.ogg 8s
EOF
assert_output && pass
cleanup


announce "use an alias with semi-colons"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias jibberish \"play foo.ogg;play bar.ogg\""
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: jibberish"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play foo.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play foo.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play bar.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play bar.ogg
EOF
assert_output && pass
cleanup


announce "use an alias with semi-colons sub-aliases"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias foo play foo.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias bar play bar.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias jibberish \"foo;bar\""
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: jibberish"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play foo.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play foo.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play bar.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play bar.ogg
EOF
assert_output && pass
cleanup


announce "use a recursive alias"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla babble"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble blabla"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: babble"
cat > test.expected <<EOF
PRIVMSG #test :lexer/expand error: max recursion reached
EOF
assert_output && pass
cleanup


announce "use a recursive alias in a multi-command"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla babble;blabla"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias babble blabla;babble"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: babble"
cat > test.expected <<EOF
PRIVMSG #test :lexer/expand error: max recursion reached
EOF
assert_output && pass
cleanup


announce "list all known aliases alphabetically"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias zelda play zelda.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias beer play beer.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: aliases"
cat > test.expected <<EOF
PRIVMSG #test :known aliases: beer, blabla, zelda
EOF
assert_output && pass
cleanup


announce "grep"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias zelda play zelda.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias beer play beer.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: grep a"
cat > test.expected <<EOF
PRIVMSG #test :blabla, zelda
EOF
assert_output && pass
cleanup


announce "random"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias beer play beer.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: random"
cat > test.expected <<EOF
PRIVMSG #test :the codes have chosen beer
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play beer.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play beer.ogg
EOF
assert_output && pass
cleanup


announce "random pattern"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias beer play beer.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias bees play bees.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: random beer"
cat > test.expected <<EOF
PRIVMSG #test :the codes have chosen beer
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play beer.ogg
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play beer.ogg
EOF
assert_output && pass
cleanup


announce "grep no result"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias zelda play zelda.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias beer play beer.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: grep y"
cat > test.expected <<EOF
PRIVMSG #test :error: no results
EOF
assert_output && pass
cleanup


# FIXME: grep too many results


announce "list aliases by pages of 400 bytes at most"
for each in 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do
	test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias randomlongaliasfromhell$each play stuff.ogg"
done
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: aliases"
cat > test.expected <<EOF
PRIVMSG #test :known aliases: randomlongaliasfromhell0, randomlongaliasfromhell1, randomlongaliasfromhell2, randomlongaliasfromhell3, randomlongaliasfromhell4, randomlongaliasfromhell5, randomlongaliasfromhell6, randomlongaliasfromhell7, randomlongaliasfromhell8, randomlongaliasfromhell9, randomlongaliasfromhellA, randomlongaliasfromhellB, randomlongaliasfromhellC, randomlongaliasfromhellD, randomlongaliasfromhellE, randomlongaliasfromhellF, randomlongaliasfromhellG
PRIVMSG #test :... randomlongaliasfromhellH, randomlongaliasfromhellI, randomlongaliasfromhellJ, randomlongaliasfromhellK, randomlongaliasfromhellL, randomlongaliasfromhellM, randomlongaliasfromhellN, randomlongaliasfromhellO, randomlongaliasfromhellP, randomlongaliasfromhellQ, randomlongaliasfromhellR, randomlongaliasfromhellS, randomlongaliasfromhellT, randomlongaliasfromhellU, randomlongaliasfromhellV, randomlongaliasfromhellW, randomlongaliasfromhellX
PRIVMSG #test :... randomlongaliasfromhellY, randomlongaliasfromhellZ
EOF
assert_output && pass
cleanup


announce "too many aliases to list"
for each in 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do
	test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias randomlongaliasfromhella$each play stuff.ogg"
	test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias randomlongaliasfromhellb$each play stuff.ogg"
done
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: aliases"
cat > test.expected <<EOF
PRIVMSG #test :error: too many results, use grep
EOF
assert_output && pass
cleanup


announce "alias with percent sign"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias 60% play stuff"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias 60%"
cat > test.expected <<EOF
PRIVMSG #test :60%="play stuff" (created by jimmy on 2000-01-01T00:00:00Z)
EOF
assert_output && pass
cleanup


announce "unalias usage"
rm -f test.aliases
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: unalias"
cat > test.expected <<EOF
PRIVMSG #test :usage: unalias name
EOF
assert_output && pass


announce "try to delete a non-existing alias"
rm -f test.aliases
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias notblabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: unalias blabla"
cat > test.expected <<EOF
PRIVMSG #test :error: unknown alias
EOF
assert_output && pass


announce "delete an existing alias"
rm -f test.aliases
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla play stuff.ogg"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: unalias blabla"
# make sure it has really gone
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias blabla"
cat > test.expected <<EOF
PRIVMSG #test :error: unknown alias
EOF
assert_output && pass
cleanup


announce "say stuff (unknown minions)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: say stuff"
cat > test.expected <<EOF
PRIVMSG #ygor :error: unable to load queue URLs, minion not found: pi1
EOF
assert_output && pass
cleanup


announce "bad roster file (wrong param count)"
echo "123	123	123" > test.roster
test_line_error "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/ygor-minion-pi2"
cat > test.expected <<EOF
EOF
assert_output || fail
cat > test.expected <<EOF
minions file error: minion line is missing parameters
EOF
assert_stderr && pass
cleanup


announce "bad roster file (bad timestamp)"
echo "123	123	123	qwe" > test.roster
test_line_error "minion user_id_234234234 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
cat > test.expected <<EOF
EOF
assert_output || fail
cat > test.expected <<EOF
minions file error: minion line has an invalid timestamp
EOF
assert_stderr && pass
cleanup


announce "say stuff"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: say stuff"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 say -v bruce stuff
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 say -v bruce stuff
EOF
assert_output && pass
cleanup


announce "say stuff (wrong channel)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #stuff :whygore: say stuff"
cat > test.expected <<EOF
PRIVMSG #ygor :error: #stuff has no queue(s) configured
EOF
assert_output && pass
cleanup


announce "use alias"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: alias 60% play stuff"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: 60%"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 play stuff
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 play stuff
EOF
assert_output && pass
cleanup


announce "sshhhh"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: sshhhh"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 shutup
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 shutup
PRIVMSG #test :ok...
EOF
assert_output && pass
cleanup


# This test is to make sure we don't catch words starting with stop...
announce "stopwhining"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: stopwhining"
cat > test.expected <<EOF
PRIVMSG #test :command not found: stopwhining
EOF
assert_output && pass
cleanup


announce "sshhhh by ignored nick"
test_line "irc :douchebot!dev@truveris.com PRIVMSG #test :whygore: sshhhh"
cat > test.expected <<EOF
EOF
assert_output && pass
cleanup


announce "sshhhh privately (not owner)"
test_line "irc :jimmy!dev@truveris.com PRIVMSG whygore :whygore: sshhhh"
cat > test.expected <<EOF
PRIVMSG jimmy :command not found: sshhhh
EOF
assert_output && pass
cleanup


announce "image"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: image http://imgur.com/stuff"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 xombrero open http://truveris.github.io/fullscreen-image/?http://imgur.com/stuff
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 xombrero open http://truveris.github.io/fullscreen-image/?http://imgur.com/stuff
EOF
assert_output && pass
cleanup


announce "xombrero"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: xombrero open http://www.truveris.com/"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 xombrero open http://www.truveris.com/
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 xombrero open http://www.truveris.com/
EOF
assert_output && pass
cleanup


announce "xombrero ack"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
test_line "minion user_id_1234567890 xombrero ok"
cat > test.expected <<EOF
EOF
assert_output && pass
cleanup


announce "xombrero error (known minion)"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
test_line "minion user_id_1234567890 xombrero error stuff"
cat > test.expected <<EOF
PRIVMSG #test :xombrero@pi1: error stuff
EOF
assert_output && pass
cleanup


announce "xombrero error (unknown minion)"
test_line "minion user_id_1234567890 register pi1 https://nom.nom/super-train/bobert"
test_line "minion user_id_1234567891 register pi2 https://nom.nom/super-train/jo"
test_line "minion user_id_1234567892 xombrero error stuff"
cat > test.expected <<EOF
PRIVMSG #ygor :xombrero: can't find minion for user_id_1234567892
EOF
assert_output && pass
cleanup


announce "reboot"
test_line "minion user_id_234234234 register pi1 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1"
test_line "minion user_id_123123123 register pi2 http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2"
test_line "irc :jimmy!dev@truveris.com PRIVMSG #test :whygore: reboot"
cat > test.expected <<EOF
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi1 reboot
[SQS-SendToMinion] http://sqs.us-east-1.amazonaws.com/000000000000/minion-pi2 reboot
PRIVMSG #test :attempting to reboot #test minions...
EOF
assert_output && pass
cleanup
