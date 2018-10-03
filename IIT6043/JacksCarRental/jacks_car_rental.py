import numpy as np

GAMMA = 0.9
RENT_COST = 10
MOVING_COST = -2


def poisson(avg) :
    ret = np.zeros((21))
    for i in range(21) :
        ret[i] = (avg ** i) * np.exp(-avg) / np.math.factorial(i)
    return ret;
    
def clip(x) :
    if x < 0 :
        return 0
    elif x > 20 :
        return 20
    else :
        return x

#Get Poisson Distributions for requests and returns.
requestof1st = poisson(3)
returnof1st = poisson(3)
requestof2nd = poisson(4)
returnof2nd = poisson(2)

# Set Transition Array (station_1, station_2, next_station_1, next_station_2))
transition = np.zeros((21, 21, 21, 21))
# Set Transition Reward Array (station_1, station_2))
transition_reward = np.zeros((21, 21))


for it_1 in range(21) :
    for it_2 in range(21) :
        transition_1 = np.zeros(21)
        transition_2 = np.zeros(21)
        for reqit in range(21) :
            for retit in range(21) :
                transition_1[clip(it_1 - reqit + retit)] += requestof1st[reqit] * returnof1st[retit]
                transition_reward[it_1][it_2] += RENT_COST * (reqit if it_1 - reqit + retit >= 0 else it_1) * requestof1st[reqit] * returnof1st[retit]
        for reqit in range(21) :
            for retit in range(21) :
                transition_2[clip(it_2 - reqit + retit)] += requestof2nd[reqit] * returnof2nd[retit]
                transition_reward[it_1][it_2] += RENT_COST * (reqit if it_2 - reqit + retit >= 0 else it_2) * requestof2nd[reqit] * returnof2nd[retit]
        transition[it_1][it_2][:][:] = np.outer(transition_1, transition_2)
print("MAKING TRANSITION ARRAY COMPLETED")
#Firstly Set policy as zeros
policy = np.zeros((21, 21), dtype=np.int32)
reward = np.zeros((21, 21))
# 1000 Iterations
for iter in range(1, 1001) :
    new_reward = np.zeros((21, 21))
    # Calculate next policy greedy
    for it_1 in range(21) :
        for it_2 in range(21) :
            for policy_it in range ( max(it_1 - 20, -it_2, -5), min(it_1, 20 - it_2, 5) + 1 ) :
                cur_reward = MOVING_COST * abs(policy_it) + \
                  transition_reward[it_1 - policy_it][it_2 + policy_it] +\
                  GAMMA * (np.sum(np.multiply(transition[it_1 - policy_it][it_2 + policy_it], reward)))
                if new_reward[it_1][it_2] < cur_reward :
                    new_reward[it_1][it_2] = cur_reward
                    policy[it_1][it_2] = policy_it
    reward = new_reward
    # output to text file
    if(iter < 10 or (iter < 100 and iter % 10 == 0) or iter % 100 == 0) :
        fw_p = open("policy_" + str(iter) + ".txt", "w")
        fw_r = open("reward_" + str(iter) + ".txt", "w")
        for it_1 in range(21) :
            for it_2 in range(21) :
                fw_p.write(str(policy[it_1][it_2]) + "\t")
                fw_r.write(str(reward[it_1][it_2]) + "\t")
            fw_p.write("\n")
            fw_r.write("\n")