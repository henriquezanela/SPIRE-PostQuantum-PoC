#!/bin/bash

reset_spire() {
     kill -9 $(ps -ef | grep "spire-agent" | grep -v grep | awk '{print $2}')
     kill -9 $(ps -ef | grep "spire-server" | grep -v grep | awk '{print $2}')
     rm -rf $MODIFIED_SPIRE/.data
}

reset_spire
sleep 1

start_spire_server () {
    # Start the SPIRE Server as a background process
    echo "Starting spire-server..."
    sleep 1
    $MODIFIED_SPIRE/bin/spire-server run -config $MODIFIED_SPIRE/conf/server/server.conf &
    sleep 2
}
start_spire_server


generate_jointoken () {
# Generate a one time Join Token.
echo "Generating token..."
sleep 1
tmp=$( $MODIFIED_SPIRE/bin/spire-server token generate -spiffeID spiffe://example.org/host)
echo $tmp
token=${tmp:7}
# echo $token >> tokens.lst
echo -e "Generated token: $token. \n Ready to start a new agent."
}

start_spire_agent () {
    generate_jointoken
    # Start the SPIRE Agent as a background process using the token passed by parameter.
    echo "Starting spire-agent..."
    sleep 1
    $MODIFIED_SPIRE/bin/spire-agent run -joinToken $token -config $MODIFIED_SPIRE/conf/agent/agent.conf &
    token=''
}
start_spire_agent
