#!/bin/bash
DATADIR="/home/scott/Desktop/smileycoin/.smileycoin"
rm -rf "$DATADIR"
mkdir -p "$DATADIR"/regtest
touch "$DATADIR/regtest/debug.log"
tail -q -n 1 -F "$DATADIR/regtest/debug.log" | grep -m 1 -q "Done loading" &
WAITER=$!
PORT=`expr $BASHPID + 10000`
"/home/scott/Desktop/smileycoin/src/smileycoind" -connect=0.0.0.0 -datadir="$DATADIR" -rpcuser=user -rpcpassword=pass -listen -keypool=3 -debug -debug=net -logtimestamps -port=$PORT -regtest -rpcport=`expr $PORT + 1` &
smileycoind=$!

#Install a watchdog.
(sleep 10 && kill -0 $WAITER 2>/dev/null && kill -9 $smileycoind $$)&
wait $WAITER

if [ -n "$TIMEOUT" ]; then
  timeout "$TIMEOUT"s "$@" $PORT
  RETURN=$?
else
  "$@" $PORT
  RETURN=$?
fi

(sleep 15 && kill -0 $smileycoind 2>/dev/null && kill -9 $smileycoind $$)&
kill $smileycoind && wait $smileycoind

# timeout returns 124 on timeout, otherwise the return value of the child
exit $RETURN
