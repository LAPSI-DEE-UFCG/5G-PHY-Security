# 5G-PHY-Security

Repository for research and development of beam signature detection techniques aiming at physical layer security in 5G networks, focusing on experimentation and analysis through Machine Learning.

## Project Structure

- **Beam_Signature_Detection_Models.ipynb**  
  Python/Jupyter Notebook that performs analysis and experiments with beam signature detection models.  
  Includes:
  - Loading and preprocessing of data (datasets in `.mat` format exported from MATLAB).
  - Training and evaluation of Machine Learning algorithms for beam pattern identification.
  - Visualization of results and performance metrics.

- **Dataset_Creation/**  
  Directory containing MATLAB scripts and various files for generation, manipulation, and export of synthetic beam signature datasets.
  - Main scripts:  
    - `gen_dataset.m`, `gen_waveform.m`, `generateDataSet.m`, among others, responsible for simulating antenna array scenarios, beam sweeping, and measurement.
    - Auxiliary functions for azimuth/elevation calculation, point generation, array manipulation, and result export.
  - Generated datasets:  
    - `.mat` files such as `dataset_2.mat`, `dataset_3.mat`, ... containing the data that feeds the analysis notebook.
  - Supporting files:  
    - Array images, validation files, visualization scripts.

> **Note:** The list above presents only part of the files. See all files and scripts at [Dataset_Creation](https://github.com/LAPSI-DEE-UFCG/5G-PHY-Security/tree/main/Dataset_Creation).

## Workflow

1. **Dataset Generation**
   - Run the MATLAB scripts in `Dataset_Creation/` to simulate and generate the required data.
   - The results are saved as `.mat` files in this same directory.

2. **Modeling and Detection**
   - Import the `.mat` files into `Beam_Signature_Detection_Models.ipynb`.
   - Follow the notebook steps for analysis, model training, and visualization of results.

## Technologies Used

- **MATLAB**: Simulation, generation, and export of synthetic datasets.
- **Python/Jupyter Notebook**: Modeling, algorithm training, and data analysis.
- **Machine Learning**: Classification algorithms for beam signature detection.

## Contributing

Contributions, suggestions, and corrections are welcome! Use the Issues or Pull Requests system.

## Developers

João Pedro Melquiades Gomes
Matheus Vilarim P. dos Santos
Edmar C. Gurjão

## Contact

lapsi@dee.ufcg.edu.br or ecg@dee.ufcg.edu.br

## License

This project is licensed under the BSD License.

---

**Questions or suggestions?**  
Contact the maintainers or open an Issue.
