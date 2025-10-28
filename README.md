
```python
# Add a new field 'address' to the schema
new_data = [
    {"name": "Jane Smith", "email": "jane.smith@email.com", "phone": "123-456-7890", "address": "123 Main St"},
    {"name": "John Doe", "email": "johndoe@email.com", "phone": "234-567-8900", "address": "456 Oak Ave"}
]

new_df = spark.createDataFrame(new_data)
new_df.write.format("delta").mode("append").option("mergeSchema", "true").save("/path/to/delta_table")



```

# Databricks Training

---


## Big Data

![alt text](assets/images/cluster_racks.png)


### Suggested Readings (Not in order):
1. CAP Theorem:
    - https://www.scylladb.com/glossary/cap-theorem/
    - https://medium.com/@ngneha090/understanding-the-cap-theorem-balancing-consistency-availability-and-partition-cb11c2b97e2b
    - https://www.bmc.com/blogs/cap-theorem/
2. https://researchcomputing.princeton.edu/faq/what-is-a-cluster

---

<div align="center">
Made with ❤️ by Nikhil Sharma
</div>

