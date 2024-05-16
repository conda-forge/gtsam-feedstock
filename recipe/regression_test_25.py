# originally from https://github.com/conda-forge/gtsam-feedstock/issues/25

import gtsam
import numpy as np

graph = gtsam.NonlinearFactorGraph()

pose_key = gtsam.symbol('x', 0)
vel_key = gtsam.symbol('v', 0)
bias_key = gtsam.symbol('b', 0)

current_pose = gtsam.Pose3(np.eye(4))
current_vel = np.zeros(3)
current_bias = gtsam.imuBias.ConstantBias()

graph.add(gtsam.PriorFactorPose3(pose_key, current_pose, gtsam.noiseModel.Isotropic.Sigma(6, 0.1)))
graph.add(gtsam.PriorFactorVector(vel_key, current_vel, gtsam.noiseModel.Isotropic.Sigma(3, 0.1)))
graph.add(gtsam.PriorFactorConstantBias(bias_key, current_bias, gtsam.noiseModel.Isotropic.Sigma(6, 0.1)))

initial_estimate = gtsam.Values()
initial_estimate.insert(pose_key, current_pose)
initial_estimate.insert(vel_key, current_vel)
initial_estimate.insert(bias_key, current_bias)

pose_key += 1
vel_key += 1
bias_key += 1

new_pose = gtsam.Pose3(np.eye(4))
graph.add(gtsam.PriorFactorPose3(pose_key, new_pose, gtsam.noiseModel.Diagonal.Sigmas(np.array([0.1, 0.1, 0.1, 0.1, 0.1, 0.1]))))

imu_accum = gtsam.PreintegratedImuMeasurements(gtsam.PreintegrationParams(np.asarray([0, 0, 9.81])))
predicted_nav_state = imu_accum.predict(gtsam.NavState(current_pose, current_vel), current_bias)
imu_factor = gtsam.ImuFactor(pose_key-1, vel_key-1, pose_key, vel_key, bias_key, imu_accum)
graph.add(imu_factor)

initial_estimate.insert(pose_key, predicted_nav_state.pose())
initial_estimate.insert(vel_key, predicted_nav_state.velocity())
initial_estimate.insert(bias_key, gtsam.imuBias.ConstantBias())

bias_factor = gtsam.BetweenFactorConstantBias(bias_key-1, bias_key, gtsam.imuBias.ConstantBias(), gtsam.noiseModel.Diagonal.Sigmas(np.array([0.1, 0.1, 0.1, 0.1, 0.1, 0.1])))
graph.add(bias_factor)

isam = gtsam.ISAM2(gtsam.ISAM2Params())
result = isam.update(graph, initial_estimate)
