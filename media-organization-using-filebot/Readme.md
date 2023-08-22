## How to organize files using filebot cli
1. Download and setup filebot portable version. Caution: Use the right version of java or you will get unknown errors.
2. Run the following command to organize a folder full of movies
```sh
./filebot.sh -script fn:amc "/mnt/mydrive/Movies" --output "/mnt/mydrive/Movies2" --action TEST -non-strict --order Airdate --conflict skip --lang en --def 'ut_label=Movie' 'music=y' 'unsorted=y' 'clean=y' 'skipExtract=y' 'excludeList=.excludes' --log all --log-file 'filebot.log' -non-strict --def excludeList=amc-ex.txt --def movieFormat="{plex}" seriesFormat="{plex}" animeFormat="{plex}" --def movieDB=TheMovieDB seriesDB=TheTVDB animeDB=AniDB
```
3. Copy the final out put to a file `filebot.out`. The file output looks like `[TEST] from [/mnt/mydrive/Movies/.../xxxx] to [/mnt/mydrive/Movies2/yyyy]`
4. Run the following python code on that file
```py
import re
import os
import shutil

lines = open('filebot.out','r')
for line in lines:
    # print(line)
    vals = re.match("\[TEST\] from \[(.*)\] to \[(.*)\]", line)
    if vals:
        src=vals.group(1)
        dest=vals.group(2)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.move(src, dest)
```
5. Check and delete the original `Movies` folder
6. The organized media is in `Movies2` folder
