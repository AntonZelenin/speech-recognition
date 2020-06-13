import os
from shutil import copyfile, rmtree
import re

DIR_PATH = 'training-data/checkpoints_512'
CHECKPOINTS_DIR = 'training-data/checkpoints_512/'
BEST_DEV = 'best_dev_checkpoint'
CHECKPOINT = 'checkpoint'
FLAGS = 'flags.txt'
CHECKPOINTS_TMP = 'training-data/checkpoints_tmp/'

os.mkdir(CHECKPOINTS_TMP)
copyfile(CHECKPOINTS_DIR + BEST_DEV, CHECKPOINTS_TMP + BEST_DEV)
copyfile(CHECKPOINTS_DIR + FLAGS, CHECKPOINTS_TMP + FLAGS)
copyfile(CHECKPOINTS_DIR + CHECKPOINT, CHECKPOINTS_TMP + CHECKPOINT)
with open(CHECKPOINTS_DIR + BEST_DEV) as f:
    best_checkpoint = re.search(r'best_dev-[0-9]+', f.read()).group(0)
    for file in os.listdir(CHECKPOINTS_DIR):
        if file.startswith(best_checkpoint):
            copyfile(CHECKPOINTS_DIR + file, CHECKPOINTS_TMP + file)
rmtree(CHECKPOINTS_DIR)
os.rename(CHECKPOINTS_TMP, CHECKPOINTS_DIR)
