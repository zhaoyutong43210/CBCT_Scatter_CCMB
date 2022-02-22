from model_unet6_clinical import *
from data import *
import tensorflow as tf
import matplotlib.pyplot as plt  
import csv
import numpy as np
#os.environ["CUDA_VISIBLE_DEVICES"] = "0"


data_gen_args = dict(rotation_range=0.1,
                    #width_shift_range=0.3,
                    #height_shift_range=0.3,
                    #shear_range=0.1,
                    zoom_range=0.01,
                    horizontal_flip=True,
                    #vertical_flip = True,
                    validation_split = 0.1,
                    fill_mode='nearest')

image_datagen = ImageDataGenerator(**data_gen_args)
mask_datagen = ImageDataGenerator(**data_gen_args)


myTriGene = trainGenerator(1,'data/clinical_305655_trainingset/train','image','label',image_datagen,mask_datagen,target_size = (384,512) )

#model = unet(input_size= (384,512,1))
model = unet(input_size= (384,512,1), pretrained_weights = './data/clinical_305655_trainingset/unet4_Iheu2_p7_Jan19.hdf5')

model_checkpoint = ModelCheckpoint('./data/clinical_305655_trainingset/unet4_Iheu2_p8_Jan19.hdf5', monitor='loss',verbose=1, save_best_only=True)
history = model.fit(
    myTriGene,
    steps_per_epoch=805,
    epochs=100,
    callbacks=[model_checkpoint],
    validation_data = myTriGene,
    validation_steps = 100
    )

testGene = testGenerator("data/clinical_305655_trainingset/test1",num_image = 30,target_size = (384,512))
results = model.predict(testGene,verbose=1)
saveResult("data/clinical_305655_trainingset/testa",results)



print(history.history.keys()) 

plt.figure(1)  
   
 # summarize history for accuracy  
   
#plt.subplot(211)  
plt.plot(history.history['MSE'])  
#plt.plot(history.history['loss'])  
plt.plot(history.history['val_MSE'])  
plt.plot(history.history['val_loss'])  
plt.title('model accuracy')  
plt.ylabel('loss')  
plt.xlabel('epoch')  
plt.legend(['MSE', 'loss','val_MSE','val_loss'], loc='upper left')  

# Write the training curve in to a data file

train_history = history.history;
train_result = train_history.items()
train_curvedata = list(train_result)

with open("train_history0525.txt", "w") as output:
    output.write(str(train_curvedata))

