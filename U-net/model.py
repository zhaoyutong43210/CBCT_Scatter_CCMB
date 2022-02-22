# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# This model is based on the paper "Projection-domain scatter correction for cone beam computed tomography 
# using a residual convolutional neural network"
# see https://pubmed.ncbi.nlm.nih.gov/31077390/ or https://sci-hub.se/10.1002/mp.13583
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# Yutong Zhao, CancerCare Manitoba
# Jan 26th 2021
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

import numpy as np 
import os
import skimage.io as io
import skimage.transform as trans
import numpy as np
from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint, LearningRateScheduler
from tensorflow.keras import backend as keras
 
def unet(pretrained_weights = None,input_size = (360,360,1)):
    inputs = Input(input_size)
    
    conv1 = Conv2D(32, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(inputs)
    #bn1 = BatchNormalization()(conv1)
    pool1 = MaxPool2D(pool_size=(2, 2))(conv1)
    # Zeroth layer depth = 32 kernel = 3*3
    
    conv2a = Conv2D(64, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool1)
    bn2a = BatchNormalization()(conv2a)
    conv2b = Conv2D(64, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn2a)
    bn2b = BatchNormalization()(conv2b)
    pool2 = MaxPool2D(pool_size=(2, 2))(bn2b)
    # First layer depth = 64 kernel = 7*7, with 2 conv2D layers
    
    conv3a = Conv2D(128, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool2)
    bn3a = BatchNormalization()(conv3a)
    conv3b = Conv2D(128, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn3a)
    bn3b = BatchNormalization()(conv3b)
    pool3 = MaxPool2D(pool_size=(3, 3))(bn3b)
    # Second layer depth = 64 kernel = 7*7, with 2 conv2D layers
    
    conv4a = Conv2D(256, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool3)
    bn4a = BatchNormalization()(conv4a)
    conv4b = Conv2D(256, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn4a)
    bn4b = BatchNormalization()(conv4b)
    #drop4 = Dropout(0.5)(conv4)
    pool4 = MaxPool2D(pool_size=(2,2))(bn4b) 
    # Third layer depth = 256, kernel size = 7*7, The pool_size should be 2 instead of 3!

    conv5a = Conv2D(512, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(pool4)
    bn5a = BatchNormalization()(conv5a)
    conv5b = Conv2D(512, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn5a)
    bn5b = BatchNormalization()(conv5b)
    conv5c = Conv2D(512, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn5b)
    bn5c = BatchNormalization()(conv5c)
    # drop5 = Dropout(0.5)(conv5)
    # Fourth layer depth = 512, kernel size = 7*7 

    up6 = (UpSampling2D(size = (2,2))(bn5c))
    merge6 = concatenate([bn4b,up6], axis = 3)
    conv6a = Conv2D(256, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge6)
    bn6a = BatchNormalization()(conv6a)
    conv6b = Conv2D(256, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn6a)
    bn6b = BatchNormalization()(conv6b)
    # Thrid UpConv, depth = 256, kernel size = 7*7
    

    up7 = (UpSampling2D(size = (3,3))(bn6b))
    merge7 = concatenate([bn3b,up7], axis = 3)
    conv7a = Conv2D(128, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge7)
    bn7a = BatchNormalization()(conv7a)
    conv7b = Conv2D(128, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn7a)
    bn7b = BatchNormalization()(conv7b)
    # Second UpConv, depth = 128, kernel size = 7*7
    
    up8 = (UpSampling2D(size = (2,2))(bn7b))
    merge8 = concatenate([bn2b,up8], axis = 3)
    conv8a = Conv2D(64, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge8)
    bn8a = BatchNormalization()(conv8a)
    conv8b = Conv2D(64, 7, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(bn8a)
    bn8b = BatchNormalization()(conv8b)
    # First UpConv, depth = 64, kernel size = 7*7
    
    up9 =  (UpSampling2D(size = (2,2))(bn8b))
    merge9 = concatenate([conv1,up9], axis = 3)
    conv9 = Conv2D(32, 3, activation = 'relu', padding = 'same', kernel_initializer = 'he_normal')(merge9)
    
    # Zeroth UpConv, depth = 64, kernel size = 3*3
    

    model = Model(inputs = inputs, outputs = conv9)

    model.compile(optimizer = Adam(lr = 1e-4), loss = 'MSE', metrics = ['accuracy'])
    
    # loss =  'binary_crossentropy' (original), 'MAE', 'MSE'
    
    #model.summary()

    if(pretrained_weights):
    	model.load_weights(pretrained_weights)

    return model


