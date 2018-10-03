import numpy as np

P_HEAD = 0.4
GAMMA = 1.0

# initial values of states are 0
values = [0.] * 101

# the rewards of state 0-99 are 0
rewards = [0.] * 101
# except the final state
rewards[100] = 1.

# initial policy of state 0-99 are 0
policy = [0] * 100

delta = 100000

iter = 0
while delta > 1e-20 : # the value is optimal therefore no changes occured
    iter += 1
    delta = 0.
    newvalues = [0] * 100
    for it_state in range(100) :
        for it_action in range(1, min(it_state, 100 - it_state) + 1) :
            newval =P_HEAD * (rewards[it_state + it_action] + GAMMA * values[it_state + it_action]) +\
                (1. - P_HEAD) * (rewards[it_state - it_action] + GAMMA * values[it_state - it_action])
            if np.round(newval, 5) > np.round(newvalues[it_state], 5) :
                newvalues[it_state] = newval
                policy[it_state] = it_action
        if delta < (abs(values[it_state] - newvalues[it_state])) :
            delta = abs(values[it_state] - newvalues[it_state])
    values[:100] = newvalues[:]
    #logging
    print("Iter " + str(iter) + "  delta : " + str(delta))
    fw_p = open("log/policy_" + str(iter) + ".txt", "w")
    fw_v = open("log/value_" + str(iter) + ".txt", "w")
    for it_state in range(100) :
        fw_p.write(str(policy[it_state]) + "\n")
        fw_v.write(str(values[it_state]) + "\n")