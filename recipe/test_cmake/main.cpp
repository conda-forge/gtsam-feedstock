#include <gtsam/geometry/Pose3.h>

int main() {
  const gtsam::Pose3 pose;
  return pose.equals(gtsam::Pose3::Identity()) ? 0 : 1;
}
