def normalize(skills):
    return {s.strip().lower() for s in skills if s and s.strip()}


def match_job(user_skills, required_skills):
    user = normalize(user_skills)
    required = [s.strip().lower() for s in required_skills.split(",") if s.strip()]
    if not required:
        return 0, []
    missing = [s for s in required if s not in user]
    matched = len(required) - len(missing)
    return round(100 * matched / len(required)), missing


def rank_jobs(user_skills, jobs):
    results = []
    for job in jobs:
        percent, missing = match_job(user_skills, job["required_skills"])
        results.append({
            "id": job["id"],
            "title": job["title"],
            "company": job["company"],
            "match_percent": percent,
            "missing_skills": missing,
        })
    return sorted(results, key=lambda r: (-r["match_percent"], r["title"]))
