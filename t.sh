docker run -v /run/media/Data/speech_dataset/:/datasets --gpus all -it cuda-tensorflow-cudnn7.6

export TF_FORCE_GPU_ALLOW_GROWTH=true

nano training/deepspeech_training/evaluate.py # line 79
nano training/deepspeech_training/train.py # line 242

# FINE-TUNING
python3 DeepSpeech.py \
--alphabet_config_path ../datasets/mozilla/alphabet.txt \
--save_checkpoint_dir ../datasets/low_rate_checkpoints \
--load_checkpoint_dir ../datasets/hight_rate_checkpoints \
--train_files   ../datasets/mozilla/clips/train.csv \
--dev_files   ../datasets/mozilla/clips/dev.csv \
--automatic_mixed_precision=True \
--n_hidden 2048 \
--train_cudnn \
--dropout_rate 0.25 \
--learning_rate 0.0001 \
--train_batch_size 32 \
--dev_batch_size 32

# TRAIN A NEW MODEL
python3 DeepSpeech.py \
--alphabet_config_path ../datasets/mozilla/alphabet.txt \
--checkpoint_dir ../datasets/checkpoints \
--train_files   ../datasets/mozilla/clips/train.csv \
--dev_files   ../datasets/mozilla/clips/dev.csv \
--automatic_mixed_precision=True \
--train_cudnn \
--dropout_rate 0.3 \
--learning_rate 0.0001 \
--train_batch_size 48 \
--dev_batch_size 48 \
--n_hidden 1024 \
--epochs 5

# TRAIN A MODEL with augmentation
python3 DeepSpeech.py \
--alphabet_config_path ../datasets/mozilla/alphabet.txt \
--checkpoint_dir ../datasets/checkpoints_512 \
--train_files   ../datasets/mozilla/clips/validated.csv \
--dev_files   ../datasets/mozilla/clips/my_dev.csv \
--automatic_mixed_precision=True \
--train_cudnn \
--dropout_rate 0.3 \
--learning_rate 0.0001 \
--train_batch_size 128 \
--dev_batch_size 128 \
--n_hidden 512 \
--epochs 7 \
--data_aug_features_additive 0.2 \
--augmentation_freq_and_time_masking \
--augmentation_freq_and_time_masking_freq_mask_range 5 \
--augmentation_freq_and_time_masking_number_freq_masks 3 \
--augmentation_freq_and_time_masking_time_mask_range 2 \
--augmentation_freq_and_time_masking_number_time_masks 3 \
--augmentation_pitch_and_tempo_scaling \
--augmentation_pitch_and_tempo_scaling_min_pitch 0.9 \
--augmentation_pitch_and_tempo_scaling_max_pitch 1.2 \
--augmentation_pitch_and_tempo_scaling_max_tempo 1.2