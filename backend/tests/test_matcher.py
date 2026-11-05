from matcher import match_job, rank_jobs


def test_match_job_partial():
    percent, missing = match_job(["python", "docker", "sql"], "python,flask,docker,sql")
    assert percent == 75
    assert missing == ["flask"]


def test_match_job_ignores_case_and_spaces():
    percent, missing = match_job([" Python ", "DOCKER"], "python,docker")
    assert percent == 100
    assert missing == []


def test_match_job_no_overlap():
    percent, missing = match_job(["java"], "python,docker")
    assert percent == 0
    assert missing == ["python", "docker"]


def test_rank_jobs_sorted_best_first():
    jobs = [
        {"id": 1, "title": "A", "company": "X", "required_skills": "java,spring"},
        {"id": 2, "title": "B", "company": "Y", "required_skills": "python,docker"},
    ]
    ranked = rank_jobs(["python", "docker"], jobs)
    assert ranked[0]["title"] == "B"
    assert ranked[0]["match_percent"] == 100
    assert ranked[1]["match_percent"] == 0
