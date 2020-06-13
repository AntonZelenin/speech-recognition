import os
from time import time

import pyaudio
import wave
import click

CHUNK = 1024
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000
RECORD_SECONDS = 2

TRAINING_DATA = 'training-data'
# DIR = 'train'
DIR = 'dev'
# DIR = 'test'

# array of phrases to record
phrases = [
    'тест'
]


p = pyaudio.PyAudio()

for phrase in phrases:
    while True:
        print(f"Recording: {phrase}")
        click.confirm("Press enter when you are ready", default='y')

        stream = p.open(format=FORMAT,
                        channels=CHANNELS,
                        rate=RATE,
                        input=True,
                        frames_per_buffer=CHUNK)

        print("* recording")

        frames = []

        for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
            data = stream.read(CHUNK)
            frames.append(data)

        print("* done recording")

        stream.stop_stream()
        stream.close()

        if click.confirm('OK?', default='y'):
            name = os.path.join(TRAINING_DATA, DIR, 'greeting_' + str(time()) + '.wav')
            wf = wave.open(name, 'wb')
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(p.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()

            with open(os.path.join(TRAINING_DATA, DIR, DIR + '.csv'), 'a+') as f:
                f.write(f'{name};{os.path.getsize(name)};{phrase}\r\n')
            break

p.terminate()
