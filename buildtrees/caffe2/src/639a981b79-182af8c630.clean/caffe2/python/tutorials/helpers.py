## @package helpers
# Module caffe2.python.tutorials.helpers
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals
import numpy as np
import skimage.io
import skimage.transform


def crop_center(img, cropx, cropy):
    y, x, c = img.shape
    startx = x // 2 - (cropx // 2)
    starty = y // 2 - (cropy // 2)
    return img[starty:starty + cropy, startx:startx + cropx]


def rescale(img, input_height, input_width):
    # print("Original image shape:" + str(img.shape) + " --> it should be in H, W, C!")
    # print("Model's input shape is %dx%d") % (input_height, input_width)
    aspect = img.shape[1] / float(img.shape[0])
    # print("Orginal aspect ratio: " + str(aspect))
    if(aspect > 1):
        # landscape orientation - wide image
        res = int(aspect * input_height)
        imgScaled = skimage.transform.resize(
            img,
            (input_width, res),
            preserve_range=False)
    if(aspect < 1):
        # portrait orientation - tall image
        res = int(input_width / aspect)
        imgScaled = skimage.transform.resize(
            img,
            (res, input_height),
            preserve_range=False)
    if(aspect == 1):
        imgScaled = skimage.transform.resize(
            img,
            (input_width, input_height),
            preserve_range=False)
    return imgScaled


def load(img):
    # load and transform image
    img = skimage.img_as_float(skimage.io.imread(img)).astype(np.float32)
    return img


def chw(img):
    # switch to CHW
    img = img.swapaxes(1, 2).swapaxes(0, 1)
    return img


def bgr(img):
    # switch to BGR
    img = img[(2, 1, 0), :, :]
    return img


def removeMean(img, mean):
    # remove mean for better results
    img = img * 255 - mean
    return img


def batch(img):
    # add batch size
    img = img[np.newaxis, :, :, :].astype(np.float32)
    return img


def parseResults(results):
    results = np.asarray(results)
    results = np.delete(results, 1)
    index = 0
    highest = 0
    arr = np.empty((0, 2), dtype=object)
    arr[:, 0] = int(10)
    arr[:, 1:] = float(10)
    for i, r in enumerate(results):
        # imagenet index begins with 1!
        i = i + 1
        arr = np.append(arr, np.array([[i, r]]), axis=0)
        if (r > highest):
            highest = r
            index = i

    # top 3 results
    print("Raw top 3 results:", sorted(arr, key=lambda x: x[1], reverse=True)[:3])

    # now we can grab the code list
    with open('inference_codes.txt', 'r') as f:
        for line in f:
            code, result = line.partition(":")[::2]
            if (code.strip() == str(index)):
                answer = "The image contains a %s with a %s percent probability." \
                    % (result.strip()[1:-2], highest * 100)
    f.closed
    return answer


def loadToNCHW(img, mean, input_size):
    img = load(img)
    img = rescale(img, input_size, input_size)
    img = crop_center(img, input_size, input_size)
    img = chw(img)
    img = bgr(img)
    img = removeMean(img, mean)
    img = batch(img)
    return img
