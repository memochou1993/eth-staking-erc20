const delay = (seconds) => new Promise((res) => setTimeout(() => res(), 1000 * seconds));
const getArgs = (tx) => tx.logs.at(0).args;
const getEvent = (tx) => tx.logs.at(0).event;

module.exports = {
  delay,
  getArgs,
  getEvent,
};
