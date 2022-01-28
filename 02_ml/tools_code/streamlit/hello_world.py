import streamlit as st
import numpy as np
import pandas as pd

# To run:
#   export LC_ALL=C.UTF-8
#   export LANG=C.UTF-8
#       Reason: unix command line is in bytes; python uses unicode text model
#       More details: https://click.palletsprojects.com/en/7.x/python3/
#   streamlit run examples/streamlit/hello_world.py &

# Reference API: https://docs.streamlit.io/en/stable/api.html#

# -------------------------------------------------------
# Add title
# -------------------------------------------------------
st.title('Data App')


# -------------------------------------------------------
# Create DF
# -------------------------------------------------------
st.header("Data Generation")
st.write("Here's our first attempt at using data to create a table:")
st.write(pd.DataFrame({
    'first column': [1, 2, 3, 4],
    'second column': [10, 20, 30, 40]
}))


# Create DF with magic; don't need st.write
st.write("Here's our second attempt at using data to create a table with magic")
df = pd.DataFrame({
    'first column': [1, 2, 3, 4],
    'second column': [10, 20, 30, 40]
})
df

# -------------------------------------------------------
# Plots
# -------------------------------------------------------
st.header("Plots")
st.subheader("Line Graphs")
st.line_chart(df)

st.subheader("Plot map")
map_data = pd.DataFrame(
    np.random.randn(1000, 2) / [50, 50] + [37.76, -122.4],
    columns=['lat', 'lon'])
st.map(map_data)

st.subheader("Matplotlib")
import matplotlib.pyplot as plt
import numpy as np
arr = np.random.normal(1, 1, size=100)
fig, ax = plt.subplots()
ax.hist(arr, bins=20)
st.pyplot(fig)



# -------------------------------------------------------
# Interactive widgets
# -------------------------------------------------------
st.header("Interactive widgets")
st.subheader("Checkbox: show/hide data")
if st.checkbox('Show dataframe'):
    chart_data = pd.DataFrame(
        np.random.randn(20, 3),
        columns=['a', 'b', 'c'])
    st.line_chart(chart_data)

st.subheader('Select box for options')
#option = st.selectbox(
#    'Which number do you like best?',
#     df['first column'])

#st.write('You selected: ', option)



# -------------------------------------------------------
# Layout
# -------------------------------------------------------
st.header("Layout")

option_layout = st.sidebar.selectbox(
    'Which number do you like best?',
     df['first column'])

st.write('You selected:', option_layout)

left_column, right_column = st.beta_columns(2)
pressed = left_column.button('Press me?')
if pressed:
    right_column.write("Woohoo!")

expander = st.beta_expander("FAQ")
expander.write("Here you could put in some really, really long explanations...")


# -------------------------------------------------------
# Progress
# -------------------------------------------------------
st.header('Progress')
import time
'Starting a long computation...'

# Add a placeholder
latest_iteration = st.empty()
bar = st.progress(0)

for i in range(100):
  # Update the progress bar with each iteration.
  latest_iteration.text(f'Iteration {i+1}')
  bar.progress(i + 1)
  time.sleep(0.1)

'...and now we\'re done!'