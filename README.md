# App for Motion Tracking Analysis for Cricket Batting

Evaluating the motion of an athlete is of great importance as it can result in the enhancement of performance during matches and training sessions. Additionally, the potential of developing an inexpensive, accessible and quality analysis tool has substantial consequences for the amateur cricket community worldwide. The goal of this project was to develop a sensor based framework to classify cricket batting shots, along with other performance metrics in real-time. Using gyroscope and accelerometer sensors, a gaussian SVM algorithm was optimised using Scikit learn to classify 5 broad batting strokes; defensive, drive, cut, pull and sweep, using a variety of players and a total of 538 shots collected prior to the data analysis. This classification algorithm has a overall accuracy of 86.8% (93.5% for detection and 92.8% for classification).

![Phone App](README%20Media/App%20Screenshots.png "iPhone App Screens")

A real time application was created using the iPhone / Apple Watch ecosystem to classify each shot and display performance statistics of bat speed, shot quality and bat angles to the user in real time. The application classification was carried out initially using a neural network (NN) algorithm with the optimisation done by Apple using their Activity Classifier designed for sensory motion data. The gaussian SVM algorithm was then also integrated into the app, giving two different real time algorithms to compare. The real time algorithms both had the same detection process and were tested using another 550 shots and 140 shots respectively. The detection accuracy was 90.0% with the NN resulting in an overall accuracy of 68.6% (76.2% for classification) and the gaussian SVM with an overall accuracy of 79.1% (87.9% for classification).

![Watch App](README%20Media/Screenshot%202022-06-09%20at%2014.26.02.png "Apple Watch App")

This application is now able to provide the basis for objective skill assessment, focusing on personal improvements for different players. Adding more classes to the algorithm, generalising for a wider range of players and inferring performance improvements from the data collected are all areas that will improve the classification and develop this project further`

![Action](README%20Media/Screenshot%202022-06-12%20at%2014.56.16.png "Using App in a Cricket Net Session")



