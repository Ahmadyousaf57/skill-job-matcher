CREATE TABLE IF NOT EXISTS jobs (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  company TEXT NOT NULL,
  required_skills TEXT NOT NULL
);

INSERT INTO jobs (title, company, required_skills) VALUES
('DevOps Engineer Intern', 'CloudNest', 'linux,docker,git,bash'),
('Junior DevOps Engineer', 'InfraWorks', 'linux,docker,kubernetes,jenkins,git'),
('Cloud Engineer', 'SkyBridge', 'aws,terraform,linux,networking'),
('Backend Developer', 'CodeCraft', 'python,flask,postgresql,docker'),
('Python Developer', 'ByteLabs', 'python,django,sql,git'),
('Site Reliability Engineer', 'ScaleWorks', 'linux,kubernetes,prometheus,grafana,python'),
('Platform Engineer', 'InfraHub', 'terraform,kubernetes,aws,helm,git'),
('DevSecOps Engineer', 'SecureStack', 'docker,jenkins,sonarqube,linux,git'),
('Data Analyst', 'DataBridge', 'python,sql,excel,pandas'),
('Frontend Developer', 'PixelForge', 'html,css,javascript,react,git'),
('Cloud Support Associate', 'SkyDesk', 'aws,linux,networking,bash'),
('Automation Engineer', 'AutoFlow', 'python,bash,ansible,linux,git'),
('Full Stack Developer', 'StackNest', 'python,flask,javascript,postgresql,docker'),
('Machine Learning Engineer', 'NeuralWorks', 'python,pandas,tensorflow,sql,docker'),
('Kubernetes Administrator', 'ClusterOps', 'kubernetes,linux,helm,docker,prometheus');
