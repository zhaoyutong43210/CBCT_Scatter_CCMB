import numpy as np 
import os
import skimage.io as io
import skimage.transform as trans
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import *
from tensorflow.keras.layers import *
from tensorflow.keras.optimizers import *
from tensorflow.keras.callbacks import ModelCheckpoint, LearningRateScheduler
from tensorflow.keras import backend as keras
from tensorflow.keras.utils import plot_model
# import matplotlib.pyplot as plt  


def unet(pretrained_weights = None,input_size = (1024,768,1)):
    
   # myinitializer = tf.keras.layers.LeakyReLU(alpha=0.01)
    myactivation = tf.keras.layers.LeakyReLU(alpha=0.05)
    myinitializer = 'HeNormal'
    ini_filters = 32
    
    inputs = Input(input_size)
    inputs2 = GaussianNoise(stddev = 0.05)(inputs)
    conv1 = Conv2D(ini_filters, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(inputs2)
    conv1 = BatchNormalization()(conv1)
    conv1 = Conv2D(ini_filters, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv1)
    conv1 = BatchNormalization()(conv1)
    drop1 = Dropout(0.5)(conv1)
    pool1 = MaxPooling2D(pool_size=(2, 2))(drop1)
    
    conv2 = Conv2D(ini_filters*2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool1)
    conv2 = BatchNormalization()(conv2)
    conv2 = Conv2D(ini_filters*2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv2)
    conv2 = BatchNormalization()(conv2)
    drop2 = Dropout(0.5)(conv2)
    pool2 = MaxPooling2D(pool_size=(2, 2))(drop2)
    
    conv3 = Conv2D(ini_filters*4, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool2)
    conv3 = BatchNormalization()(conv3)
    conv3 = Conv2D(ini_filters*4, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv3)
    conv3 = BatchNormalization()(conv3)
    drop3 = Dropout(0.5)(conv3)
    pool3 = MaxPooling2D(pool_size=(2, 2))(drop3)
    
    conv4 = Conv2D(ini_filters*8, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool3)
    conv4 = BatchNormalization()(conv4)
    conv4 = Conv2D(ini_filters*8, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv4)
    conv4 = BatchNormalization()(conv4)
    drop4 = Dropout(0.5)(conv4)
    pool4 = MaxPooling2D(pool_size=(2, 2))(drop4)

    conv5 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool4)
    conv5 = BatchNormalization()(conv5)
    conv5 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv5)
    conv5 = BatchNormalization()(conv5)
    drop5 = Dropout(0.5)(conv5)
    pool5 = MaxPooling2D(pool_size=(2, 2))(drop5)
    
    conv6 = Conv2D(ini_filters*32, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool5)
    conv6 = BatchNormalization()(conv6)
    conv6 = Conv2D(ini_filters*32, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv6)
    conv6 = BatchNormalization()(conv6)
    drop6 = Dropout(0.5)(conv6)
    pool6 = MaxPooling2D(pool_size=(2, 2))(drop6)
    
    conv7 = Conv2D(ini_filters*64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool6)
    conv7 = BatchNormalization()(conv7)
    conv7 = Conv2D(ini_filters*64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv7)
    conv7 = BatchNormalization()(conv7)
    drop7 = Dropout(0.5)(conv7)

    up8 = Conv2D(ini_filters*32, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop7))
    merge8 = concatenate([drop6,up8], axis = 3)
    conv8 = Conv2D(ini_filters*32, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge8)
    conv8 = BatchNormalization()(conv8)
    conv8 = Conv2D(ini_filters*32, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv8)
    conv8 = BatchNormalization()(conv8)
    drop8 = Dropout(0.5)(conv8)

    up9 = Conv2D(ini_filters*16, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop8))
    merge9 = concatenate([drop5,up9], axis = 3)
    conv9 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge9)
    conv9 = BatchNormalization()(conv9)
    conv9 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv9)
    conv9 = BatchNormalization()(conv9)
    drop9 = Dropout(0.5)(conv9)

    up10 = Conv2D(ini_filters*8, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop9))
    merge10 = concatenate([drop4,up10], axis = 3)
    conv10 = Conv2D(ini_filters*8, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge10)
    conv10 = BatchNormalization()(conv10)
    conv10 = Conv2D(ini_filters*8, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv10)
    conv10 = BatchNormalization()(conv10)
    drop10 = Dropout(0.5)(conv10)

    up11 = Conv2D(ini_filters*4, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop10))
    merge11 = concatenate([conv3,up11], axis = 3)
    conv11 = Conv2D(ini_filters*4, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge11)
    conv11 = BatchNormalization()(conv11)
    conv11 = Conv2D(ini_filters*4, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv11)
    conv11 = BatchNormalization()(conv11)
    drop11 = Dropout(0.5)(conv11)
    
    up12 = Conv2D(ini_filters*2, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop11))
    merge12 = concatenate([conv2,up12], axis = 3)
    conv12 = Conv2D(ini_filters*2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge12)
    conv12 = BatchNormalization()(conv12)
    conv12 = Conv2D(ini_filters*2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv12)
    conv12 = BatchNormalization()(conv12)
    drop12 = Dropout(0.5)(conv12)
    
    up13 = Conv2D(ini_filters*16, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop12))
    merge13 = concatenate([conv1,up13], axis = 3)
    conv13 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge13)
    conv13 = BatchNormalization()(conv13)
    conv13 = Conv2D(ini_filters*16, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv13)
    conv13 = BatchNormalization()(conv13)
    drop13 = Dropout(0.5)(conv13)
    
    conv14 = Conv2D(2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv13)
    conv9 = BatchNormalization()(conv9)
    conv15 = Conv2D(1, 1, activation = 'sigmoid')(conv14)

    model = Model(inputs = inputs, outputs = conv15)

    model.compile(optimizer = Adam(lr = 1e-4), loss = 'MSE', metrics=['MSE'])
    
    print(model.summary())
    
    plot_model(model, to_file='unet6.png', show_shapes=True, show_layer_names=True)
    
    if(pretrained_weights):
    	model.load_weights(pretrained_weights)

    return model 


