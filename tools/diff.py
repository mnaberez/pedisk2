'''
Compare two PEDISK image files and print track/sector differences.
Usage: diff.py <a.img> <b.img>
'''
import sys

import imageutil

def diff(img_a, img_b):
    if img_a.__class__ != img_b.__class__:
        raise Exception("Images of different types can't be diffed")
    diff_list = [] # [(t,s), (t,s), (t,s), ...]
    sector_size = img_a.SECTOR_SIZE
    img_a.home()
    img_b.home()
    done = False
    while not done:
        t_s = (img_a.track, img_b.sector)
        if img_a.read(sector_size) != img_b.read(sector_size):
            diff_list.append(t_s)
        # done if position wrapped around
        done = (img_a.track == 0) and (img_a.sector == 1)
    return diff_list

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 3:
            sys.stderr.write(__doc__)
            sys.exit(1)
        name_a, name_b = sys.argv[1:]

        img_a = imageutil.DiskImage.read_file(name_a)
        img_b = imageutil.DiskImage.read_file(name_b)
        for t_s in diff(img_a, img_b):
            print("Track %d, Sector %d differ" % t_s)
    main()
