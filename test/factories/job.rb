valid_job_ids = [1,2,3,4,5,6,7,8,9,11]

Factory.define :job do |job|
  i = valid_job_ids[rand(valid_job_ids.length)]
  job.name Job::JOBS[i]
  job.color Job::JOB_COLORS[i]
end
