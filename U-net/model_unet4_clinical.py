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


def unet(pretrained_weights = None,input_size = (768,1024,1)):
    
    #myregularizer = tf.keras.regularizers.L1(0.01)
    myactivation = tf.keras.layers.LeakyReLU(alpha=0.05);
    myinitializer = 'HeNormal';
    
    inputs = Input(input_size)
    inputs2 = GaussianNoise(stddev = 0.01)(inputs)
    conv1 = Conv2D(64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(inputs2)
    conv1 = BatchNormalization()(conv1)
    conv1 = Conv2D(64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv1)
    conv1 = BatchNormalization()(conv1)
    pool1 = MaxPooling2D(pool_size=(2, 2))(conv1)
    
    conv2 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool1)
    conv2 = BatchNormalization()(conv2)
    conv2 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv2)
    conv2 = BatchNormalization()(conv2)
    pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)
    
    conv3 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool2)
    conv3 = BatchNormalization()(conv3)
    conv3 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv3)
    conv3 = BatchNormalization()(conv3)
    drop3 = Dropout(0.75)(conv3)
    pool3 = MaxPooling2D(pool_size=(2, 2))(conv3)
    
    conv4 = Conv2D(512, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool3)
    conv4 = BatchNormalization()(conv4)
    conv4 = Conv2D(512, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv4)
    conv4 = BatchNormalization()(conv4)
    drop4 = Dropout(0.75)(conv4)
    pool4 = MaxPooling2D(pool_size=(2, 2))(drop4)

    conv5 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(pool4)
    conv5 = BatchNormalization()(conv5)
    conv5 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv5)
    conv5 = BatchNormalization()(conv5)
    drop5 = Dropout(0.75)(conv5)

    up6 = Conv2D(128, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(drop5))
    merge6 = concatenate([drop4,up6], axis = 3)
    conv6 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge6)
    conv6 = BatchNormalization()(conv6)
    conv6 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv6)
    conv6 = BatchNormalization()(conv6)

    up7 = Conv2D(256, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(conv6))
    merge7 = concatenate([conv3,up7], axis = 3)
    conv7 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge7)
    conv7 = BatchNormalization()(conv7)
    conv7 = Conv2D(256, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv7)
    conv7 = BatchNormalization()(conv7)

    up8 = Conv2D(128, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(conv7))
    merge8 = concatenate([conv2,up8], axis = 3)
    conv8 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge8)
    conv8 = BatchNormalization()(conv8)
    conv8 = Conv2D(128, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv8)
    conv8 = BatchNormalization()(conv8)

    up9 = Conv2D(64, 2, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(UpSampling2D(size = (2,2))(conv8))
    merge9 = concatenate([conv1,up9], axis = 3)
    conv9 = Conv2D(64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(merge9)
    conv9 = BatchNormalization()(conv9)
    conv9 = Conv2D(64, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv9)
    conv9 = BatchNormalization()(conv9)
    conv9 = Conv2D(2, 3, activation = myactivation, padding = 'same', kernel_initializer = myinitializer)(conv9)
    #conv9 = BatchNormalization()(conv9)
    conv10 = Conv2D(1, 1, activation = 'sigmoid')(conv9)

    model = Model(inputs = inputs, outputs = conv10)

    model.compile(optimizer = Adam(lr = 1e-4), loss = 'MSE', metrics=['MSE'])
    
    print(model.summary())
    
    plot_model(model, to_file='unet4.png', show_shapes=True, show_layer_names=True)
    
    if(pretrained_weights):
    	model.load_weights(pretrained_weights)

    return model 


