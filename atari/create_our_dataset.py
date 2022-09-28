import pickle, os, glob
import numpy as np

def c_continious_done_idx(done_idx):
        done_idx_cont = [done_idx[0]-1]
        for i in range(1,len(done_idx)):
            done_idx_cont.append(done_idx_cont[i-1]+done_idx[i])
        return done_idx_cont

def c_timesteps(done_idx):
    timesteps= []
    for x in done_idx:
        for i in range(0,x):
            timesteps.append(i)
    return timesteps

def c_rtgs(returns, rewards, done_idx):
    rtgs = []
    start_idx = 0
    game_idx = 0
    for i in range(0,len(done_idx)):
        ret = returns[game_idx]
        #print(start_idx, i, done_idx[i])
        for reward in rewards[start_idx:start_idx+done_idx[i]-1]:
            ret -= reward
            rtgs.append(ret)
        start_idx = done_idx[i]
        game_idx += 1
    return rtgs

def convert(path):
        obss, actions, returns, done_idx, rewards = [], [], [], [], []
        #for x in glob.glob("/data/SL/pong/obss_dqn/*.pkl"):
        #    obss += pickle.load(open(x, "rb"))
        obss += pickle.load(open(path + "obss_dqn/data_seed0.pkl", "rb"))
        obss += pickle.load(open(path + "obss_dqn/data_seed1.pkl", "rb"))
        for x in glob.glob(path + "actions/*.pkl"):
            actions += pickle.load(open(x, "rb"))
        for x in glob.glob(path + "returns/*.pkl"):
            returns += pickle.load(open(x, "rb"))
        for x in glob.glob(path +"done_idx/*.pkl"):
            done_idx += pickle.load(open(x, "rb"))
        for x in glob.glob(path +"rewards/*.pkl"):
            rewards += pickle.load(open(x, "rb"))
        timesteps = np.array(c_timesteps(done_idx))
        done_idx_cont = np.array(c_continious_done_idx(done_idx))
        rtgs = np.array(c_rtgs(returns, rewards, done_idx))
        return obss, actions, returns, done_idx_cont, rtgs, timesteps 


obss, actions, returns, done_idx, rtgs, timesteps = convert("/data/SL/pong/")

# +
#returns

# +
#rtgs[1804:1810]


# +
#rtgs[3778:3790]
# -


